//+------------------------------------------------------------------+
//|                                                  SQLite3test.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property show_inputs
#include <sqlite3.mqh>
input string dbns="C:\Testdb.db";//�ް��ް����i���߽�j

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
    string sql = "";
	int i;
	//�C���X�^���X
		CSQLite3 sqlite(dbns);
	
	//�e�[�u���̍쐬
		sql = "CREATE TABLE IF NOT EXISTS `Test` (`id` INTEGER, `time` TEXT, `open_price` DOUBLE)";
		if(sqlite.execute(sql)!= SQLITE_OK)sqlite.errmsg();
	
	//����
		sql = "INSERT INTO 'Test' VALUES (?,?,?)";
		//�g�����U�N�V����	
		if(sqlite.execute("BEGIN")!=SQLITE_OK)sqlite.errmsg();
	
		for(i=0;i<Bars;i++){
			if(sqlite.prepare(sql)!=SQLITE_OK)sqlite.errmsg();
			if(sqlite.bind_int(1,Bars-i)!=SQLITE_OK)sqlite.errmsg();
			if(sqlite.bind_text(2,TimeToStr(Time[i]))!=SQLITE_OK)sqlite.errmsg();
			if(sqlite.bind_double(3,Open[i])!=SQLITE_OK)sqlite.errmsg();
			sqlite.next_row();
		}
		//�g�����U�N�V�����I��
		if(sqlite.execute("COMMIT")!=SQLITE_OK)sqlite.errmsg();
	
		//�X�e�[�g�����g�̉�@
		sqlite.finalize();
		
	//�o��
		sql = "SELECT COUNT(*) FROM  'Test'";
		if(sqlite.prepare(sql)!=SQLITE_OK)sqlite.errmsg();
		sqlite.next_row();
		Print("Bars=",IntegerToString(Bars)," �ް��ް������ް���=",sqlite.get_text(0));
		
		//�X�e�[�g�����g�̉�@
		sqlite.finalize();
		
	//���o
		sql = "SELECT * FROM 'Test'" ;
		if(sqlite.prepare(sql)!=SQLITE_OK)sqlite.errmsg();
		while(sqlite.next_row()){
			Print(IntegerToString(
			                       sqlite.get_int(0))," : ",
			                       sqlite.get_text(1)," : ",
			                       DoubleToStr(sqlite.get_double(2),Digits));
		}
	
		//�X�e�[�g�����g�̉�@
		sqlite.finalize();
	//�ް��ް������B	
	sqlite.db_close();

  return (0);
  }
 