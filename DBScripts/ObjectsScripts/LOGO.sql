--create one folder 'LOGO' in 'D:' directory and place the Traxys LOGO file within that folder.

--In SYS user, we need to execute following scripts to grant permission to the schema for accessing the logo folder.

CREATE OR REPLACE DIRECTORY EXAMPLE AS 'D:\LOGO';
GRANT READ ON DIRECTORY EXAMPLE TO Schema_Name;
GRANT WRITE ON DIRECTORY EXAMPLE TO Schema_Name;


--Execute  The "LOAD.sql" procedure 


--After above steps, we need to run following script to load the image in DB table using 'LOAD' procedure

begin
for cc in(select ak.corporate_id from ak_corporate ak where AK.corporate_id not in('EKA-SYS'))
loop
load(cc.corporate_id,'Traxys.jpg','Traxys','Traxys');
end loop;
end;







