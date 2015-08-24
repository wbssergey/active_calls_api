<%pgTitle="Dashboard (db1)"%>

<!--#include file=../include/header2.asp-->
<!--#include file="../include/voipCustomer1.asp"-->


<style type="text/css">
.datarowx1		{background-color:#FFF8C6}

.datarowx0		{background-color:#ECE5B6}
</style>

<%
Dim voipCust
Dim spdashboard
spdashboard="proc_MySqlCdrManagerDashBoardbconf" ' by Shruti db1
Set voipCust= New voipCustomer

Server.ScriptTimeout = 4000
oConn.CommandTimeout = 4000

if syslabuser <> "sergey" then
'redirerr "under recovery"
End if
intention=rqf("action1x")


mpartition=rqf("mpartition")

minrange1= "99.01"
maxrange1= "00.01"

minrange2= "99.01"
maxrange2= "00.01"

%>


<form name="fSubmit" method=post action=''>
<input type=hidden name=cdrupdated value="<%=cdrupdated%>">
	<input type=hidden name=cdrstamp value="<%=cdrstamp%>">
		
<table class=datatable width="100%" align=left cellpadding=0 cellspacing=1 >

	<tr class=datacol0><th nowrap style=letter-spacing:1;font-size:10pt;font-weight:bold;color:#F5B800><%=PgTitle%></th>
		<td nowrap style='display:none;font-weight:bold' colspan=3 valign=bottom nowrap>&nbsp;&nbsp;
		<%=dateSelect(1,1,beginDt,endDt)%> &nbsp; &nbsp; 
        </td>
<th><input class=databutton type=button value=Apply title='Apply Filter' onclick="doSubmit('run','')">&nbsp;&nbsp;</th>
<th nowrap style='color:#F5B800'><b>Partition:&nbsp;</b><select name="mpartition" onchange="return doSubmit('run','part')">
<option value="" <%if mpartition="" then%> selected <%end if%>>-All-</option>
<%=voipCust.WritePartitionList3withshort(mpartition,syslabuser)%>
		</select> </th>
</tr>
</table></td></tr><tr><td>

<%
If intention="run" Then

sql="exec " & spdashboard & "  @transaction=1 "


oconn.execute(sql)

sql="exec " & spdashboard & " @query=1,  @userby='"&syslabuser&"' "

'sql="exec MySqlCdrManagerDashBoarddbmaster @query=1,  @userby='"&syslabuser&"' "

If mpartition <> "" Then
sql=sql & " , @partitionid="&mpartition
End If
wx(sql)
 %>
 <A name="top"></A>
<table class=datatable width="100%" >
<tr><td valign=top width="50%">
<table  width="100%" align=left cellpadding=0 cellspacing=1 >
<%
cgrand=0
sgrand=0

irec=0
igrp=0
ngrp=0
org="?"
total=0
tmc=0
'redirerr sql
set rs=oconn.execute(sql)
' Vishal
'response.write sql
while not rs.eof
status="?"
irec=irec+1
id=rs("id")
call_state=rs("call_state")
incoming_gateway_name=rs("incoming_gateway_name")	

dialpeer=rs("dialpeer")
mint=rs("mint")
maxt=rs("maxt")
If minrange1 > mint Then
minrange1=mint
End If
If maxrange1 < maxt Then
maxrange1=maxt
End If

mc=rs("mc")
If irec=1 Then
total=mc
End If
If org<>incoming_gateway_name Then
org=incoming_gateway_name
irec=1
igrp=igrp+1
If igrp <> 1 Then
cgrand=cgrand+total

%>
<tr><td></td><td align=right>Total calls(Trying):</td><td nowrap  style='text-align:center'><b><%=total%></b>(<%=tmc%>)</td>
</tr>
<%
total=mc
tmc=0
End if
%>

<tr>
<th style='text-align:center;color:#F5B800'>&nbsp;&nbsp#</th>
<th style='text-align:center;color:#F5B800' nowrap><b><%=org%></b></th>
<th style='text-align:center;color:#F5B800'>Calls</th>
<th style='text-align:center;color:#F5B800'>5</th>
<th style='text-align:center;color:#F5B800'>4</th>
<th style='text-align:center;color:#F5B800'>3</th>
<th style='text-align:center;color:#F5B800'>2</th>
<th style='text-align:center;color:#F5B800'>1</th>
</tr>
<%
Else

If call_state="trying" Then
tmc=mc
Else
total=total+Cint(mc)
End if


End if
If call_state<>"trying" Then
%>
<tr class="datarow<%=x%><%=(irec mod 2)%>">
<td nowrap  style='text-align:left'>&nbsp;&nbsp;<%=irec%>&nbsp;&nbsp;</td>
<td nowrap><%=dialpeer%>&nbsp;&nbsp;&nbsp;</td>
<td style='text-align:center'><%=mc%></td>
<%

sql="exec " & spdashboard & " @query=10, @pkey="&id

' Vishal
'response.write sql
'sql="exec MySqlCdrManagerDashBoarddbmaster @query=10, @pkey="&id


d1="0"
d2="0"
d3="0"
d4="0"
d5="0"
Set rstest=oconn.execute(sql)
' Vishal
'response.write sql
While not rstest.eof
ct=rstest("ct")
If ct=1 Then
d1=rstest("mc")
End If
If ct=2 Then
d2=rstest("mc")
End If
If ct=3 Then
d3=rstest("mc")
End If
If ct=4 Then
d4=rstest("mc")
End If
If ct=5 Then
d5=rstest("mc")
End If
rstest.movenext
Wend
rstest.close
%>
<td style='text-align:center'>&nbsp;<%=d5%>&nbsp;</td>
<td style='text-align:center'>&nbsp;<%=d4%>&nbsp;</td>
<td style='text-align:center'>&nbsp;<%=d3%>&nbsp;</td>
<td style='text-align:center'>&nbsp;<%=d2%>&nbsp;</td>
<td style='text-align:center'>&nbsp;<%=d1%>&nbsp;</td>

</tr>
<%
End if
rs.movenext
Wend
rs.close
cgrand=cgrand+total
%>
<tr><td></td><td align=right>Total calls(Trying):</td><td nowrap  style='text-align:center'><b><%=total%></b>(<%=tmc%>)</td>
</tr>
</table>
<td valign=top width="50%">
<table width="100%" align=left cellpadding=0 cellspacing=1 >
<%

sql="exec " & spdashboard & " @query=2,  @userby='"&syslabuser&"' "
If mpartition <> "" Then
sql=sql & " , @partitionid="&mpartition
End If
irec=0
igrp=0
ngrp=0
org="?"
'redirerr sql
'debugerr(sql)
total=0
tmc=0
'minrange= "99.01"
'maxrange= "00.01"
set rs=oconn.execute(sql)
while not rs.eof
status="?"
irec=irec+1
id=rs("id")
call_state=rs("call_state")
outgoing_gateway_name=rs("outgoing_gateway_name")	
mint=CStr(rs("mint"))
maxt=CStr(rs("maxt"))
If minrange2 > mint Then
minrange2=mint
End If
If maxrange2 < maxt Then
maxrange2=maxt
End If

dialpeer=rs("dialpeer")
mc=rs("mc")
If irec=1 Then
total=mc
End If
If org<>outgoing_gateway_name Then
org=outgoing_gateway_name
irec=1
igrp=igrp+1
If igrp <> 1 Then
sgrand=sgrand+total

%>
<tr><td></td><td align=right>Total calls:</td><td nowrap  style='text-align:center'><b><%=total%></b></td>
</tr>
<%
total=mc
End if
%>
<tr>
<th style='text-align:center;color:#F5B800'>&nbsp;&nbsp#</th>
<th style='text-align:center;color:#F5B800' nowrap><b><%=org%></b></th>
<th style='text-align:center;color:#F5B800'>Calls</th>
<th style='text-align:center;color:#F5B800'>5</th>
<th style='text-align:center;color:#F5B800'>4</th>
<th style='text-align:center;color:#F5B800'>3</th>
<th style='text-align:center;color:#F5B800'>2</th>
<th style='text-align:center;color:#F5B800'>1</th>
</tr>
<%
Else
If call_state="trying" Then
tmc=mc
Else
total=total+Cint(mc)
End if
End if
If call_state<>"trying" Then
%>
<tr class="datarow<%=x%><%=(irec mod 2)%>">
<td nowrap  style='text-align:left'>&nbsp;&nbsp;<%=irec%>&nbsp;&nbsp;</td>
<td nowrap><%=dialpeer%>&nbsp;&nbsp;&nbsp;</td>
<td style='text-align:center'><%=mc%></td>
<%
sql="exec " & spdashboard & " @query=20, @pkey="&id


d1="0"
d2="0"
d3="0"
d4="0"
d5="0"
Set rstest=oconn.execute(sql)
While not rstest.eof
ct=rstest("ct")
If ct=1 Then
d1=rstest("mc")
End If
If ct=2 Then
d2=rstest("mc")
End If
If ct=3 Then
d3=rstest("mc")
End If
If ct=4 Then
d4=rstest("mc")
End If
If ct=5 Then
d5=rstest("mc")
End If
rstest.movenext
Wend
rstest.close
%>
<td style='text-align:center'>&nbsp;<%=d5%>&nbsp;</td>
<td style='text-align:center'>&nbsp;<%=d4%>&nbsp;</td>
<td style='text-align:center'>&nbsp;<%=d3%>&nbsp;</td>
<td style='text-align:center'>&nbsp;<%=d2%>&nbsp;</td>
<td style='text-align:center'>&nbsp;<%=d1%>&nbsp;</td>
</tr>
<%
End if
rs.movenext
Wend
rs.close
End If 'run
sgrand=sgrand+total
If intention <> "" then
%>
<tr><td></td><td align=right>Total calls:</td><td nowrap  style='text-align:center'><b><%=total%></b></td>
</tr>
<%End if%>
</table>
</td>
</tr>
<% If intention <> "" Then %>
<tr><td colspan=2><hr></td></tr>
<tr>
<td valign=top colspan=1 >
<table  align=left cellpadding=0 cellspacing=1 >
<tr><td>&nbsp;</td><td>&nbsp;</td><td nowrap style='text-align:right'><b>Grand Total Customer Calls:</td><td nowrap  style='text-align:left'><b><%=cgrand%></b></td>
</tr>
</table></td>
<td valign=top colspan=1 >
<table  align=left cellpadding=0 cellspacing=1 >
<tr><td>&nbsp;</td><td>&nbsp;</td><td nowrap style='text-align:right'><b>Grand Total Supplier Calls:</td><td nowrap  style='text-align:left'><b><%=sgrand%></b></td>
</tr>
</table>
</td>
</tr>
<%
End if
'minrange= "99.01"
'maxrange= "00.01"

If (Not (minrange1 ="99.01" and maxrange1="00.01")) And (Not (minrange2 ="99.01" and maxrange2="00.01"))  Then

'minrange=displayDate(minrange,13)
'maxrange=displayDate(maxrange,13)
tn=displayDate(Now(),13)
ptn=""
pirow=""
pmaxrange1=""
pmaxrange2=""
pminrange1=""
pminrange2=""

ptn=rqf("tn")
If ptn <> "" then
pcgrand=rqf("cgrand")
psgrand=rqf("sgrand")

pmaxrange1=rqf("maxrange1")
pmaxrange2=rqf("maxrange2")
pminrange1=rqf("minrange1")
pminrange2=rqf("minrange2")
End if
%>

<tr><td nowrap colspan=2>&nbsp;</td></tr>
<% 
If ptn <> "" then
%>
<tr>
<td nowrap colspan=1 title="">Before:&nbsp;<%=ptn%>&nbsp;customer calls(<%=pcgrand%>) between&nbsp;<%=pmaxrange1%>&nbsp;and&nbsp;<%=pminrange1%></td>
<td nowrap colspan=1 title="">Before:&nbsp;<%=ptn%>supplier calls (<%=psgrand%>) between <%=pmaxrange2%> and <%=pminrange2%></td>
</tr>
<% End If %>
<tr>
<td nowrap colspan=1 title="">->Last:&nbsp;<%=tn%>&nbsp;customer calls(<%=cgrand%>)
between&nbsp;<%=maxrange1%>&nbsp;and&nbsp;<%=minrange1%></td>
<td nowrap colspan=1 title="">->Last:&nbsp;<%=tn%>&nbsp;supplier calls(<%=sgrand%>)between&nbsp;<%=maxrange2%>&nbsp;and &nbsp;<%=minrange2%></td>
</tr>
<% End if%>
</table>

<input type=hidden name="numrec" value="<%=irec%>" />
<input type=hidden name="action1x" value="<%=intention%>" />
<input type=hidden name="data" value="" />
<input type=hidden name="cgrand" value="<%=cgrand%>" />
<input type=hidden name="sgrand" value="<%=sgrand%>" />
<input type=hidden name="maxrange1" value="<%=maxrange1%>" />
<input type=hidden name="maxrange2" value="<%=maxrange2%>" />
<input type=hidden name="minrange1" value="<%=minrange1%>" />
<input type=hidden name="minrange2" value="<%=minrange2%>" />
<input type=hidden name="tn" value="<%=tn%>" />

</form>
<script language=javascript>

var fm=document.forms.fSubmit;

	function doSubmit(itn,prm) {
		fm.action='';
		var n,s,i,v,w;
		switch (itn.toLowerCase()) {
			case 'run':   
			if(prm=='part') {
			fm.tn.value='';
			};
			break;
			case 'showna': break;
			case 'show3h': break;
			case 'edit':
			n=fm.numrec.value;
			s=""
			for(i=1;i<=n;i++){
			v=eval("fm.chedit"+i+".checked");

             if (v)
             {
			 w=eval("fm.notes"+i+".value");
			 if(w=="") {alert("no blank notes ("+i+") ");return false;}
			 s=s+i+","
             }
			}
			if (s=="")
			{
			alert("Nothing to Do");
			return false;
			}
			fm.data.value=s;
			break;
		 }
		 		
 try{
		 	 loadSubmit();
			 }
			 catch(e)
			 {};
		fm.action1x.value=itn; 
		fm.submit();
		return false
	}
</script>


<!--#include file=../include/footer.asp-->
