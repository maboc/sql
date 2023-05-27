-- Name        : settings.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : All commons settings I like for sqlplus to work
-- ---------------------------------------------------------------------
-- 2017-01-09 : MB : Initial Version

set pages 50
set lines 200
set verify off
set serveroutput on

col bytes_gb for 99999999
col bytes_perc for a10
col column_name for a25
col database_name for a10
col description for a50
col event for a50
col host_name for a25
col index_name for a25
col index_owner for a20
col index_type for a20
col machine for a25
col maxbytes_gb for 99999999
col maxbytes_perc for a10
col member for a100
col module for a35
col name for a25
col osuser for a15
col owner for a20
col p1text for a20
col p2text for a20
col p3text for a20
col program for a35
col restore_point_time for a35
col table_name for a25
col table_owner for a20
col time for a35
col txt for a100
col username for a20
col value for a50
col wait_class for a30
