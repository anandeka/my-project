-- Create table
--DROP TABLE EOD_EOM_PROCESS_COUNT;
create table EOD_EOM_PROCESS_COUNT
(
  CORPORATE_ID               VARCHAR2(15),
  TRADE_DATE                 DATE,
  PROCESS                    VARCHAR2(5),
  CREATED_DATE               TIMESTAMP(6),
  processing_status          VARCHAR2(100)
  
);