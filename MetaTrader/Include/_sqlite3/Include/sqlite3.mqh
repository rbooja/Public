//+------------------------------------------------------------------+
//|                                                      SQLite3.mqh |
//+------------------------------------------------------------------+
#define PTR            int //32bit:int 64bit:long?
#define sqlite3_stmt   PTR
#define sqlite3        PTR
#define PTRPTR         PTR

#define SQLITE_OK           0   /* Successful result */
#define SQLITE_ERROR        1   /* SQL error or missing database */
#define SQLITE_INTERNAL     2   /* An internal logic error in SQLite */
#define SQLITE_PERM         3   /* Access permission denied */
#define SQLITE_ABORT        4   /* Callback routine requested an abort */
#define SQLITE_BUSY         5   /* The database file is locked */
#define SQLITE_LOCKED       6   /* A table in the database is locked */
#define SQLITE_NOMEM        7   /* A malloc() failed */
#define SQLITE_READONLY     8   /* Attempt to write a readonly database */
#define SQLITE_INTERRUPT    9   /* Operation terminated by sqlite_interrupt() */
#define SQLITE_IOERR       10   /* Some kind of disk I/O error occurred */
#define SQLITE_CORRUPT     11   /* The database disk image is malformed */
#define SQLITE_NOTFOUND    12   /* (Internal Only) Table or record not found */
#define SQLITE_FULL        13   /* Insertion failed because database is full */
#define SQLITE_CANTOPEN    14   /* Unable to open the database file */
#define SQLITE_PROTOCOL    15   /* Database lock protocol error */
#define SQLITE_EMPTY       16   /* (Internal Only) Database table is empty */
#define SQLITE_SCHEMA      17   /* The database schema changed */
#define SQLITE_TOOBIG      18   /* Too much data for one row of a table */
#define SQLITE_CONSTRAINT  19   /* Abort due to contraint violation */
#define SQLITE_MISMATCH    20   /* Data type mismatch */
#define SQLITE_MISUSE      21   /* Library used incorrectly */
#define SQLITE_NOLFS       22   /* Uses OS features not supported on host */
#define SQLITE_AUTH        23   /* Authorization denied */
#define SQLITE_ROW         100  /* sqlite_step() has another row ready */
#define SQLITE_DONE        101  /* sqlite_step() has finished executing */

#import "sqlite3.dll"
//int sqlite3_open(const uchar &filename[],sqlite3 &paDb);
int sqlite3_open16(string filename,sqlite3 &paDb);
int sqlite3_close(sqlite3 aDb);
//int sqlite3_prepare(sqlite3 aDb,const char &sql[],int nByte,sqlite3_stmt &pStmt,PTRPTR pzTail);
//int sqlite3_prepare16(sqlite3 aDb,string sql,int nByte,sqlite3_stmt &pStmt,PTRPTR pzTail);
int sqlite3_prepare16_v2(sqlite3 aDb,string sql,int nByte,sqlite3_stmt &pStmt,PTRPTR pzTail);
int sqlite3_exec(sqlite3 aDb,const char &sql[],PTR acallback,PTR apvoid,PTRPTR errmsg);
int sqlite3_step(sqlite3_stmt apstmt);
int sqlite3_finalize(sqlite3_stmt apstmt);
int sqlite3_reset(sqlite3_stmt apstmt);
int sqlite3_errcode(sqlite3 db);
int sqlite3_extended_errcode(sqlite3 db);
//const PTR sqlite3_errmsg(sqlite3 db);
const string sqlite3_errmsg16(sqlite3 db);
int sqlite3_bind_null(sqlite3_stmt apstmt,int icol);
int sqlite3_bind_int(sqlite3_stmt apstmt,int icol,int a);
int sqlite3_bind_int64(sqlite3_stmt apstmt,int icol,long a);
int sqlite3_bind_double(sqlite3_stmt apstmt,int icol,double a);
//int sqlite3_bind_text(sqlite3_stmt apstmt,int icol,char &a[],int len,PTRPTR destr);
int sqlite3_bind_text16(sqlite3_stmt apstmt,int icol,string a,int len,PTRPTR destr);
//int sqlite3_bind_blob(sqlite3_stmt apstmt,int icol,uchar &a[],int len,PTRPTR destr);
const PTR sqlite3_column_name(sqlite3_stmt apstmt,int icol);
int sqlite3_column_count(sqlite3_stmt apstmt);
int sqlite3_column_type(sqlite3_stmt apstmt,int acol);
int sqlite3_column_bytes(sqlite3_stmt apstmt,int acol);
int sqlite3_column_int(sqlite3_stmt apstmt,int acol);
long sqlite3_column_int64(sqlite3_stmt apstmt,int acol);
double sqlite3_column_double(sqlite3_stmt apstmt,int acol);
//const PTR sqlite3_column_text(sqlite3_stmt apstmt,int acol);
string sqlite3_column_text16(sqlite3_stmt apstmt, int acol);
const PTR sqlite3_column_blob(sqlite3_stmt apstmt,int acol);
#import

class CSQLite3{
	public:
		sqlite3       sdb;
		sqlite3_stmt  stmt;
		
			          CSQLite3(){};
			          CSQLite3(string file_name);
	                 ~CSQLite3(){if(stmt){finalize(); sqlite3_close (sdb);}};
	    
		void          db_set(string file_name);            //ﾌｧｲﾙ名のｾｯﾄ
		int           reset();                             //ｽﾃｰﾄﾒﾝﾄの初期化
		int           finalize();                          //ｽﾃｰﾄﾒﾝﾄの解放
		void          db_close(){sqlite3_close (sdb);}
		int           execute(string sql);                 //入出力のないｸｴﾘｰの実行
		int		      prepare(string sql);                 //入出力のあるｸｴﾘｰの実行
		int           col_count();                         //列数の取得
		bool          next_row();                          //次の行を取得（true：あり false：なし）
		int           bind_text(int col,string txt);       //文字ﾃﾞｰﾀの入力
		int           bind_int(int col,int integer);       //整数値の入力
		int           bind_double(int col, double dbl);    //Doubule値の入力
		int           get_int(int col);                    //整数値の出力
		double        get_double(int col);                 //Doubule値の出力
		string        get_text(int col);                   //文字ﾃﾞｰﾀの出力
		void          errmsg();                            //ｴﾗｰﾒｯｾｰｼﾞをﾌﾟﾘﾝﾄ
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSQLite3::CSQLite3(string file_name){
	if(file_name != "")db_set(file_name);
}

void CSQLite3::db_set(string file_name){
   int res =  sqlite3_open16 (file_name, sdb);
   if (res != SQLITE_OK) errmsg();
}

//+-----------------------------------------------------------------+
// int CSQLite3::reset();
// ※ｽﾃｰﾄﾒﾝﾄのリｾｯﾄ
//+-----------------------------------------------------------------+
int CSQLite3::reset(){
	int ret = 0;
	if(stmt)ret = sqlite3_reset(stmt);
	return(ret);
}
//+-----------------------------------------------------------------+
// int CSQLite3::finalize();
// ※ｽﾃｰﾄﾒﾝﾄの解放
//+-----------------------------------------------------------------+
int CSQLite3::finalize(){
	int ret = 0;
	if(stmt){
	   ret = sqlite3_finalize (stmt);
	   stmt = 0;
	}
	return(ret);
}

//+------------------------------------------------------------------+
// int CSQLite3::execute(string sql)                                                                                  
//  ※入出力のないｸﾘｴ―の実行
//  sql : ｸｴﾘｰ                       
//+------------------------------------------------------------------+
int CSQLite3::execute(string sql){
	int sq,res;
	uchar qr[];
	sq = StringToCharArray(sql,qr);
	ArrayResize(qr,sq);
	if(stmt)reset();
	res = sqlite3_exec (sdb, qr, NULL, NULL, NULL);
	return(res);
}

//+-----------------------------------------------------------------+
//  int	CSQLite3::prepare(string sql);
//  ※入出力のあるｸﾘｴｰの実行。
//  ※反復処理は、(next_row,get_col)を使用。
//  ※finalize()を使用し解放をおこなう。
//  sql : ｸｴﾘｰ                       
//+------------------------------------------------------------------+
int CSQLite3::prepare(string sql){
	int res;
	if(stmt)finalize();
	res = sqlite3_prepare16_v2(sdb, sql,StringLen(sql)*2 , stmt, NULL);
	return(res);
}
//+------------------------------------------------------------------+
// int CSQLite3::colum_count ();
// ※列数を返す。
//+------------------------------------------------------------------+
int CSQLite3::col_count(){
	return(sqlite3_column_count (stmt));
}  
//+------------------------------------------------------------------+
// bool CSQLite3::next_row ();
// ※次の行を取得する 。（true：あり false：なし）
//+------------------------------------------------------------------+
bool CSQLite3::next_row (){
	if(!stmt)return(false);
	int ret = 0;
	ret = sqlite3_step (stmt);
	return (ret == SQLITE_ROW ? true : false);
}
//+------------------------------------------------------------------+
// bind_?? ();
// ※値を入力
//+-------------------------------------------------------------------+
//文字データ
int CSQLite3::bind_text(int col,string txt){
	int ret = 0;
	ret = sqlite3_bind_text16(stmt,col,txt,StringLen(txt)*2,0);
	return (ret);
}
//整数値
int CSQLite3::bind_int(int col,int integer){
	int ret = 0;
	ret = sqlite3_bind_int(stmt,col,integer);
	return (ret);
}
//double値
int CSQLite3::bind_double(int col, double dbl){
	int ret = 0 ;
	ret = sqlite3_bind_double(stmt,col,dbl);
	return (ret);
}

//+------------------------------------------------------------------+
// column_?? ();
// ※値を取得
//+-------------------------------------------------------------------+
//整数値
int CSQLite3::get_int(int col){
	int date = 0 ;
	date = sqlite3_column_int (stmt, col);
	return (date);
}
//double値
double CSQLite3::get_double(int col){
	double date = 0.0;
	date = sqlite3_column_double (stmt, col);
	return(date);
}
//文字データ
string CSQLite3::get_text(int col){
	string date = "";
	date = sqlite3_column_text16(stmt, col);
	return(date);
}
//+------------------------------------------------------------------+
// Errmsg();
// ※ｴﾗｰﾒｯｾｰｼﾞをﾌﾟﾘﾝﾄ
//+-------------------------------------------------------------------+
void CSQLite3::errmsg(){
	Print(sqlite3_errmsg16(sdb));
}