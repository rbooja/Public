#ifndef shared_ptr_h_INCLUDED
#define shared_ptr_h_INCLUDED

//
// Implements a subset of shared_prt found at www.boost.org.
// Uses a singly linked circular list instead of a reference counter.
// Avoids extra heap allocation needed to get a shared reference counter,
// but sizeof(shared_ptr)==sizeof(void*) * 3 compared to sizeof(void*) * 2
//
// See "Handles and Exception Safety, Part 4: Tracking References without Counters"
// by Andrew Koenig and Barbara E. Moo, Feb. 2003 C++ Users Journal
//

class Use
{
	mutable const Use *next;
	mutable const Use *prev;
public:
	Use() { next=this; prev=this; }
	~Use() { remove(); }
	Use(const Use& u) { insert(u); }
	Use& operator=(const Use& u) { if (this!=&u) { remove(); insert(u); } return *this; }
	void insert(const Use& u) const { this->prev=&u; this->next=u.next; u.next->prev=this; u.next=this; }
	void remove() const { this->next->prev=this->prev; this->prev->next=this->next; }
	bool empty() const { return this==this->next; }
};

template<typename X> class shared_ptr
{
public:
	template<typename Y> friend class shared_ptr;
	explicit shared_ptr(X* ptr=0) : ptr(ptr) {}
	~shared_ptr() { if (use.empty()) delete ptr; }
	template<typename Y> shared_ptr(const shared_ptr<Y>& other): ptr(other.ptr), use(other.use) { }
	shared_ptr& operator=(const shared_ptr& a) 
	{
		if (&use==&a.use) return *this;
		if (use.empty()) delete ptr;
		use=a.use; ptr=a.ptr; return *this;
	}
	X& operator*() const { return *ptr; }
	X* operator->() const { return ptr; }
	X* get() const { return ptr; }
	bool empty() const { return use.empty(); }
	void reset(X* ptr=0) { if (use.empty()) delete ptr; ptr=ptr; use=Use(); }

private:
	X *ptr;
	Use use;
};

#endif /* shared_ptr_h_INCLUDED */
