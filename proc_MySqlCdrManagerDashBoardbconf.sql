USE [wiztel]
GO

/****** Object:  StoredProcedure [dbo].[proc_MySqlCdrManagerDashBoardbconf]    Script Date: 08/24/2015 22:27:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_MySqlCdrManagerDashBoardbconf]       
/*      
   https://72.15.129.10/dashboard1.php    
exec proc_MySqlCdrManagerDashBoardbconf @query=1, @partitionid=1, @userby='sergey'      
exec proc_MySqlCdrManagerDashBoardbconf @query=2, @partitionid=1, @userby='sergey'      
      
exec proc_MySqlCdrManagerDashBoardbconf @transaction=1      
*/      
@query int =0,      
@transaction int = 0,      
@startdate varchar(max) = '',      
@enddate varchar(max) = '',      
      
@cdrdcontext varchar(max) = 'MVTS-PRO1',       
@view varchar(1) = null,      
@partitionid int  = 0 ,      
@pkey int = 0,      
      
---      
        
@userby varchar(max) = '',      
      
@call_state varchar(max)='',      
@dialpeer varchar(max)='',      
@gateway_name varchar(max)=''      
      
as      
begin      
      
declare @q varchar(max)      
declare @q1 varchar(max)      
declare @k int      
declare @c int      
declare @i int      
declare @id int      
declare @mindt varchar(50)      
declare @maxdt varchar(50)      
declare @mc int      
declare @minutes int      
declare @notset varchar(10)      
set @notset='not set'      
declare @ShortName varchar(5);      
declare @exepath varchar(max)       
declare  @err bit      
   --*************************************** Start Create Dynamic Link Server  **************************************    
 DECLARE @serverName varchar(MAX)  ;
 DECLARE @ip varchar(16)  ;
    
 EXEC proc_DynamicLinkServer @category='dashboard',@DynamicServerName = @serverName output,
 @ip=@ip output,
 @DbName = 'WBS' , @ActionOnLinkServer = 'CREATE'        
--*************************************** End Create Dynamic Link Server  **************************************    
   
    print(@servername);
    
SELECT @exepath=virtdir from [wiztel].[dbo].[1_1partitionsetup] where partitionid=-1      
      
set @exepath=@exepath + '\manager\schedule\'      
      
set @notset='not set'      
      
      
SET NOCOUNT ON;      
      
set @ShortName=(select ShortName from wbs.dbo.[0_1partitionlist] where partitionid=@partitionid);      
      
set @ShortName=ISNULL(@ShortName,'@@@');      
print (@ShortName);      
      
      
  
      
if @query=1      
begin      
set @q='select * from (select max(id) as id ,call_state ,incoming_gateway_name, dialpeer, count(*) mc,MIN(setup_time) mint,MAX(setup_time) maxt from openquery([' + @serverName + '],      
''select id ,ts_conf_id , proto_conf_id, call_state,incoming_gateway_id, incoming_gateway_name, incoming_leg_proto, incoming_src_number,incoming_dst_number,ifnull(setup_time,0) setup_time,      
connect_time,incall_time,dialpeer,outgoing_gateway_id,outgoing_gateway_name, outgoing_leg_proto, outgoing_src_number, outgoing_dst_number      
  from wbs.class4tmcalls '') group by dialpeer,incoming_gateway_name,call_state ) x      
 where dbo.fnIfGrossmPartitionsByUserDashboard(incoming_gateway_name,'''+@userby+''' )=1 ';      
       
  if @partitionid <> 0      
  begin      
  if @ShortName<>'WNL'  set @q=@q + ' and  incoming_gateway_name like ''%_'+@ShortName+'%'' '      
   if @ShortName='WNL'   set @q=@q + ' and  (incoming_gateway_name like ''%_'+@ShortName+'%'' or       
   dbo.fnIfGrossmPartitionsXes(incoming_gateway_name) = 1 )'      
       
        
  end      
        
set @q=@q+ ' order by incoming_gateway_name, call_state,dialpeer';      
      
print(@q);      
      
exec(@q);      
      
end      
      
      
      
if @query=2      
begin      
set @q='select * from (select max(id) as id,call_state ,outgoing_gateway_name, dialpeer, count(*) mc,MIN(setup_time) mint,MAX(setup_time) maxt from openquery([' + @serverName + '],      
''select id ,ts_conf_id , proto_conf_id, call_state,incoming_gateway_id, incoming_gateway_name, incoming_leg_proto, incoming_src_number,incoming_dst_number,ifnull(setup_time,0) setup_time,      
connect_time,incall_time,dialpeer,outgoing_gateway_id,outgoing_gateway_name, outgoing_leg_proto, outgoing_src_number, outgoing_dst_number      
  from wbs.class4tmcalls '') group by dialpeer,outgoing_gateway_name,call_state ) x      
 where dbo.fnIfGrossmPartitionsByUserDashboard(outgoing_gateway_name,'''+@userby+''' )=1 ';      
       
  if @partitionid <> 0       
  begin      
        
  if @ShortName='WNL'   set @q=@q + ' and  (outgoing_gateway_name like ''%_'+@ShortName+'%'' or       
   dbo.fnIfGrossmPartitionsXes(outgoing_gateway_name) = 1 )'; -- all other      
       
 if @ShortName in ('INF','WT','HRJ') and dbo.fnIfGrossmPartitionsByUserDashboard('S_QCL',@userby)=1      
    set @q=@q + ' or  (outgoing_gateway_name like ''%_QCL%'' )';      
  else      
    if @ShortName<>'WNL'  set @q=@q + ' and  outgoing_gateway_name like ''%_'+@ShortName+'%'' ';      
            
   end      
      
set @q=@q+ ' order by outgoing_gateway_name, call_state,dialpeer';      
      
print(@q);      
      
exec(@q);      
      
end      
      
      
      
if @transaction=1      
begin      
set @q='exec xp_cmdshell ''C:\inetpub\wwwroot\wiztel\pub\manager\schedule\plink.exe -2 jmason@'+@ip+' -pw ###### -v "/home/jmason/cdrs/dashboard.sh "  < C:\inetpub\wwwroot\wiztel\pub\manager\schedule\yes.txt '' ';      
  print(@q);
   exec(@q);   
end      
      
      
if @query=10      
begin      
/*      
      
exec proc_MySqlCdrManagerDashBoardbconf @query=10 , @pkey=11372 ;       
      
*/      
      
create table #temp134 (      
call_state varchar(15) null,      
dialpeer varchar(100) null,      
gateway_name varchar(100) null);      
      
set @q1='select * from wbs.class4tmcalls where id='+CAST(@pkey as varchar);      
      
set @q='insert into #temp134 select call_state,dialpeer,incoming_gateway_name from       
openquery([' + @serverName + '],'''++@q1+''')';      
print(@q);      
exec(@q);      
select @call_state=call_state,@dialpeer=dialpeer,@gateway_name=gateway_name from #temp134;      
      
drop table #temp134;      
      
      
set @q1='select  call_state,incoming_gateway_name,       
incall_time,dialpeer      
  from wbs.class4tmcalls where call_state='''+@call_state+''' and dialpeer='''+@dialpeer+''' and  incoming_gateway_name='''+@gateway_name+''' '      
      
set @q1=replace(@q1,'''','''''');      
      
set @q='select       
  case when incall_time/60. <= 1.0 then 1 else      
  case when incall_time/60. <= 2.0 then 2 else      
  case when incall_time/60. <= 3.0 then 3 else      
  case when incall_time/60. <= 4.0 then 4 else      
  case when incall_time/60. >  4.0 then 5       
  end end end end end ct      
, count(*) mc      
from       
openquery([' + @serverName + '],'''+@q1;      
      
set @q=@q+ ''') group by  case when incall_time/60. <= 1.0 then 1 else      
  case when incall_time/60. <= 2.0 then 2 else      
  case when incall_time/60. <= 3.0 then 3 else      
  case when incall_time/60. <= 4.0 then 4 else      
  case when incall_time/60. >  4.0 then 5       
  end end end end end order by ct';      
        
  print(@q);      
  exec(@q);      
end      
      
      
if @query=20      
begin      
/*      
      
exec proc_MySqlCdrManagerDashBoardbconf @query=20 , @pkey=11412 ;       
*/      
      
create table #temp187 (      
call_state varchar(15) null,      
dialpeer varchar(100) null,      
gateway_name varchar(100) null);      
      
set @q1='select * from wbs.class4tmcalls where id='+CAST(@pkey as varchar);      
      
set @q='insert into #temp187 select call_state,dialpeer,outgoing_gateway_name from       
openquery([' + @serverName + '],'''++@q1+''')';      
print(@q);      
exec(@q);      
select @call_state=call_state,@dialpeer=dialpeer,@gateway_name=gateway_name from #temp187;      
      
drop table #temp187;      
      
      
set @q1='select  call_state,outgoing_gateway_name,       
incall_time,dialpeer      
  from wbs.class4tmcalls where call_state='''+@call_state+''' and dialpeer='''+@dialpeer+''' and  outgoing_gateway_name='''+@gateway_name+''' '      
      
set @q1=replace(@q1,'''','''''');      
      
set @q='select       
  case when incall_time/60. <= 1.0 then 1 else      
  case when incall_time/60. <= 2.0 then 2 else      
  case when incall_time/60. <= 3.0 then 3 else      
  case when incall_time/60. <= 4.0 then 4 else      
  case when incall_time/60. >  4.0 then 5       
  end end end end end ct      
, count(*) mc      
from       
openquery([' + @serverName + '],'''+@q1;      
      
set @q=@q+ ''') group by  case when incall_time/60. <= 1.0 then 1 else      
  case when incall_time/60. <= 2.0 then 2 else      
  case when incall_time/60. <= 3.0 then 3 else      
  case when incall_time/60. <= 4.0 then 4 else      
  case when incall_time/60. >  4.0 then 5       
  end end end end end order by ct';      
        
  print(@q);      
  exec(@q);      
end      
  
   print('e');  
 --*************************************** Start Drop All Temp Data **************************************    
 EXEC proc_DynamicLinkServer @DynamicServerName = @serverName,@DbName = 'WBS' , @ActionOnLinkServer = 'DROP'        
    
--*************************************** End Drop All Temp Data **************************************    
   print('e');  
      
end      

GO


