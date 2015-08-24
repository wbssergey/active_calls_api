<?php

$client = new SoapClient('https://#.#.#.#/service/?wsdl');
$headers = array();
$headers[] = new SoapHeader('http://mfisoft.ru/auth','Login','####');
$headers[] = new SoapHeader('http://mfisoft.ru/auth','Password','####');

$client->__setSoapHeaders($headers);

define('hostname','#.#.#.#');
define('username','rtu');
define('password','rtu');
define('dbname','wbs');

$dblink=mysql_connect(hostname,username,password)
 OR DIE ('Unable to connect to database! Please try again later.');
mysql_query("SET character_set_results=utf8", $dblink);
mysql_query("set names 'utf8'",$dblink);
mb_language('uni');
mb_internal_encoding('UTF-8');
mysql_select_db(dbname,$dblink);

$filter=null;


$filter=Array('type'=>'agg','operator'=>'and','childs'=>Array(

Array('type'=>'cond',
'column'=>'call_state',
'operator'=>'=',
'value'=>'connected'
),
Array('type'=>'cond',
'column'=>'dialpeer',
'operator'=>'<>',
'value'=>'xx'
)
)
);



$filter=null;
$sort=null;


$sort = Array(
Array(
'column'=>'incoming_gateway_name',
'dir'=>'desc'
),
Array(
'column'=>'dialpeer',
'dir'=>'desc'
)
);

$filter=null;
$sort=null;
$rowset = $client->selectRowset('02.2519.01',$filter,$sort,1000000,0);

$c=count($rowset);



$q="truncate table class4tmcalls;";
$result = mysql_query($q,$dblink);
if(!$result) { echo("error truncate table"."<br>".$q); exit();};


$igrp=0;
$org='?';

for($i=0;$i<$c;$i++){

 
$q='insert into class4tmcalls (';
$q=$q.'ts_conf_id,proto_conf_id,call_state,incoming_gateway_id,incoming_gateway_name,incoming_leg_proto,incoming_src_number,incoming_dst_number,'; 
$q=$q.'setup_time,connect_time,incall_time,dialpeer,outgoing_gateway_id,outgoing_gateway_name,outgoing_leg_proto,outgoing_src_number,outgoing_dst_number';
$q=$q.' ) values (';

$v=$rowset[$i]['ts_conf_id']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['proto_conf_id']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['call_state']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['incoming_gateway_id']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['incoming_gateway_name']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['incoming_leg_proto']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['incoming_src_number']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['incoming_dst_number']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['setup_time']; $q=$q.'\''.(string)$v.'\',';
$v=$rowset[$i]['connect_time']; $q=$q.'\''.(string)$v.'\',';
$v=$rowset[$i]['incall_time']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['dialpeer']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['outgoing_gateway_id']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['outgoing_gateway_name']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['outgoing_leg_proto']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['outgoing_src_number']; $q=$q.'\''.$v.'\',';
$v=$rowset[$i]['outgoing_dst_number']; $q=$q.'\''.$v.'\'';
$q=$q.')';


$result = mysql_query($q,$dblink);
if(!$result) { echo("error insert into table"."<br>".$q); exit();};
};

?>

