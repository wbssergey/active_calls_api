USE [wiztel]
GO

/****** Object:  StoredProcedure [dbo].[proc_DynamicLinkServer]    Script Date: 08/24/2015 22:31:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



         
-- =============================================                
-- Author:  Shruti Pandey                
-- Create date: 10 june 2013                
-- Description: SP for creating dynamic Link Server and creating dynamic servername too                
-- How to call: exec proc_DynamicLinkServer 'select last_cdr_date from wbs.wbs_report_data_recall1 order by y desc,m desc,d desc, h desc limit 1','72.15.129.16','odbcdbslave3','rtu','rtu'              
-- =============================================                
CREATE PROC [dbo].[proc_DynamicLinkServer]           
@DynamicServerName NVARCHAR(MAX) = '' output,      
@IP VARCHAR(20) = '' output, 
@DbName NVARCHAR(MAX)= 'wbs',      
@ActionOnLinkServer VARCHAR(MAX),      
@myTSQL NVARCHAR(MAX) = NULL,    
@selectData NVARCHAR(max)='*'  ,
@category  varchar(100) = 'hourlyreport' ,
@server varchar(50) = ''
AS                  
BEGIN                  
      /*
      MAPPING
      
      --dashboard
update [wiztel].[dbo].[1_1partitionsetup] set vlinkstatic='mvtspromaster' where id=1;
--hourlyreport
update [wiztel].[dbo].[1_1partitionsetup] set vlinkstatic1='mvtsproslave3' where id=1;
update [wiztel].[dbo].[1_1partitionsetup] set vlinkstatic1='mvtswheezy' where id=1;

--cdr transfer
update [wiztel].[dbo].[1_1partitionsetup] set vlinkstatic2='mvtsproslave3' where id=1;
--custom
update [wiztel].[dbo].[1_1partitionsetup] set vlinkstatic3='mvtspro27' where id=1;

            
      --dashboard
update [wiztel].[dbo].[1_1partitionsetup] set vlinkip='72.15.129.10'
,vodbc='mvtspromaster' where id=1;
--hourlyreport
update [wiztel].[dbo].[1_1partitionsetup] set vlinkip1='72.15.129.21' 
,vodbc1='mvtswheezy' where id=1;
--cdr transfer
update [wiztel].[dbo].[1_1partitionsetup] set vlinkip2='72.15.129.28' 
,vodbc2='mvtsproslave3' where id=1;
--custom
update [wiztel].[dbo].[1_1partitionsetup] set vlinkip3='72.15.129.27' 
,vodbc3='mvts27' where id=1;

      */
 DECLARE @LINKSTATIC  varchar(20);
 DECLARE @OPENQUERY VARCHAR(MAX)      
 SET @ActionOnLinkServer = LTRIM(RTRIM(@ActionOnLinkServer))      
 SET @DbName = LTRIM(RTRIM(@DbName))       
 if(@ActionOnLinkServer = 'CREATE')      
 BEGIN      
  DECLARE @DataSorce NVARCHAR(100),@UserName NVARCHAR(100),@Password NVARCHAR(100)      
  if(@DbName = 'wbs')  
  begin   
  if @category='dashboard'
   select @LINKSTATIC=vlinkstatic,@IP = Vlinkip ,@DataSorce = vodbc,@UserName  = vUserName,@Password = [vPassword] 
   from [1_1partitionsetup] where id = 1;
  if @category='hourlyreport'
   select @LINKSTATIC=vlinkstatic1, @IP = Vlinkip1 ,@DataSorce = vodbc1, @UserName  = vUserName,@Password = [vPassword] 
   from [1_1partitionsetup] where id = 1;
  if @category='cdrtransfer'
   select @LINKSTATIC=vlinkstatic2, @IP = Vlinkip2 ,@DataSorce = vodbc2, @UserName  = vUserName,@Password = [vPassword] 
   from [1_1partitionsetup] where id = 1;
  if @category='custom'
   select @LINKSTATIC=vlinkstatic3, @IP = Vlinkip3 ,@DataSorce = vodbc3, @UserName  = vUserName,@Password = [vPassword] 
   from [1_1partitionsetup] where id = 1;
   
   if CHARINDEX('@',@category) > 0
   begin
 -- local compatibility format
 --  set @category='@myname@myip';
   set @LINKSTATIC=left(right(@category,len(@category)-1),charindex('@',right(@category,len(@category)-1))-1);
   set @IP=replace(@category,'@'+@LINKSTATIC+'@','');
   
   end;
     -- IP depends on category and is used outside  
   SET @DynamicServerName = 'DY' + SUBSTRING(REPLACE(NEWID(),'-',''),1,5) + @ip;
   
   
   if isnull(@LINKSTATIC,'')<>'' and CHARINDEX('ignore',@LINKSTATIC)=0 
               set @DynamicServerName=@LINKSTATIC; 
     
     print(@DynamicServerName);
        
 end;
 
  if CHARINDEX('DY',@DynamicServerName)=1 
  begin      
     EXEC sp_addlinkedserver  @DynamicServerName,@srvproduct='oledbforodbc',@provider='MSDASQL',
     @datasrc=@DataSorce,@location = @IP                         
     exec sp_addlinkedsrvlogin @DynamicServerName, 'false', null, @UserName,@Password      
  end;
              
 END      
 ELSE IF (@ActionOnLinkServer = 'DROP')      
 BEGIN
 
  if CHARINDEX('DY',@DynamicServerName)<> 1 return; 
    
begin try
print('drop');   
exec sp_dropserver @DynamicServerName, 'droplogins' ;     
end try
begin catch
end catch;
 
 END      
 ELSE IF (@ActionOnLinkServer = 'QUERY')      
 BEGIN     
   
 --- if name is D_XXXXX_A.B.C.D  it must be in brackets  [D_XXXXX_A.B.C.D]  
  SET @OPENQUERY = ' SELECT ' + @selectData + ' FROM OPENQUERY(['+ @DynamicServerName + '],''' + @myTSQL + ''') '            
  EXEC (@OPENQUERY)               
  /*
   INSERT INTO #LinkServerDataTempTbl            
  EXEC proc_DynamicLinkServer @DynamicServerName = @serverName, @ActionOnLinkServer = 'QUERY',
  @myTSQL = @myTSQL            

  */              
 END                    
                    
END;



GO


