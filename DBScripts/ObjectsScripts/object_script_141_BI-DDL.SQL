DROP TABLE DIM_POSITION_TYPES CASCADE CONSTRAINTS
/

CREATE TABLE DIM_POSITION_TYPES
(
  POSITION_TYPE_ID        VARCHAR2(500 CHAR),
  POSITION_TYPE           VARCHAR2(500 CHAR),
  POSITION_SUB_TYPE_ID    VARCHAR2(500 CHAR),
  POSITION_SUB_TYPE       VARCHAR2(500 CHAR),
  POSITION_DISPLAY_ORDER  VARCHAR2(500 CHAR),
  MAIN_TYPE_ID            VARCHAR2(500 CHAR),
  MAIN_TYPE               VARCHAR2(500 CHAR)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/

CREATE INDEX IDX_DIMPT1 ON DIM_POSITION_TYPES (POSITION_TYPE_ID);

SET DEFINE OFF;
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Physical - Open Purchase', 'Physical Open', '1', 'Purchase', '1', '1', 'Physical');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Physical - Open Sales', 'Physical Open', '1', 'Sales', '2', '1', 'Physical');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Flat - Purchase', 'Flat', '2', 'Purchase', '3', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Flat - Sales', 'Flat', '2', 'Sales', '4', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Unpriced - Purchase', 'Unpriced', '3', 'Purchase', '5', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Unpriced - Sales', 'Unpriced', '3', 'Sales', '6', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Stocks -  Actual Stocks', 'Stock', '4', 'Actual Stocks', '7', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Long Futures', 'Net Hedge Trades', '5', 'Long Futures', '8', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Short Futures', 'Net Hedge Trades', '5', 'Short Futures', '9', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Long Futures', 'Hedge Trades', '6', 'Long Futures', '10', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Short Futures', 'Hedge Trades', '6', 'Short Futures', '11', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Long Futures', 'Strategic Trades', '7', 'Long Futures', '12', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Short Futures', 'Strategic Trades', '7', 'Short Futures', '13', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Long Futures', 'Pricing Trades', '8', 'Long Futures', '14', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Short Futures', 'Pricing Trades', '8', 'Short Futures', '15', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Long Futures', 'Derivative Trades', '9', 'Long Futures', '16', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Short Futures', 'Derivative Trades', '9', 'Short Futures', '17', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Long Forwards', 'Net Hedge Trades', '5', 'Long Forwards', '18', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Short Forwards', 'Net Hedge Trades', '5', 'Short Forwards', '19', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Long Forwards', 'Hedge Trades', '6', 'Long Forwards', '20', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Short Forwards', 'Hedge Trades', '6', 'Short Forwards', '21', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Long Forwards', 'Strategic Trades', '7', 'Long Forwards', '22', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Short Forwards', 'Strategic Trades', '7', 'Short Forwards', '23', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Long Forwards', 'Pricing Trades', '8', 'Long Forwards', '24', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Short Forwards', 'Pricing Trades', '8', 'Short Forwards', '25', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Long Forwards', 'Derivative Trades', '9', 'Long Forwards', '26', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Short Forwards', 'Derivative Trades', '9', 'Short Forwards', '27', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Long Calls', 'Net Hedge Trades', '5', 'Long Calls', '28', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Short Calls', 'Net Hedge Trades', '5', 'Short Calls', '29', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Long Calls', 'Hedge Trades', '6', 'Long Calls', '30', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Short Calls', 'Hedge Trades', '6', 'Short Calls', '31', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Long Calls', 'Strategic Trades', '7', 'Long Calls', '32', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Short Calls', 'Strategic Trades', '7', 'Short Calls', '33', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Long Calls', 'Pricing Trades', '8', 'Long Calls', '34', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Short Calls', 'Pricing Trades', '8', 'Short Calls', '35', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Long Calls', 'Derivative Trades', '9', 'Long Calls', '36', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Short Calls', 'Derivative Trades', '9', 'Short Calls', '37', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Long Puts', 'Net Hedge Trades', '5', 'Long Puts', '38', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Short Puts', 'Net Hedge Trades', '5', 'Short Puts', '39', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Long Puts', 'Hedge Trades', '6', 'Long Puts', '40', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Short Puts', 'Hedge Trades', '6', 'Short Puts', '41', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Long Puts', 'Strategic Trades', '7', 'Long Puts', '42', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Short Puts', 'Strategic Trades', '7', 'Short Puts', '43', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Long Puts', 'Pricing Trades', '8', 'Long Puts', '44', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Short Puts', 'Pricing Trades', '8', 'Short Puts', '45', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Long Puts', 'Derivative Trades', '9', 'Long Puts', '46', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Short Puts', 'Derivative Trades', '9', 'Short Puts', '47', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Long Swaps', 'Net Hedge Trades', '5', 'Long Swaps', '48', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Net Hedge Trades - Short Swaps', 'Net Hedge Trades', '5', 'Short Swaps', '49', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Long Swaps', 'Hedge Trades', '6', 'Long Swaps', '50', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Hedge Trades - Short Swaps', 'Hedge Trades', '6', 'Short Swaps', '51', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Long Swaps', 'Strategic Trades', '7', 'Long Swaps', '52', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Strategic Trades - Short Swaps', 'Strategic Trades', '7', 'Short Swaps', '53', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Long Swaps', 'Pricing Trades', '8', 'Long Swaps', '54', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Pricing Trades - Short Swaps', 'Pricing Trades', '8', 'Short Swaps', '55', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Long Swaps', 'Derivative Trades', '9', 'Long Swaps', '56', '2', 'Net');
Insert into DIM_POSITION_TYPES
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER, MAIN_TYPE_ID, MAIN_TYPE)
 Values
   ('Derivative Trades - Short Swaps', 'Derivative Trades', '9', 'Short Swaps', '57', '2', 'Net');
COMMIT;



CREATE TABLE DIM_UNRPNL_TYPE
(
  POSITION_TYPE_ID        VARCHAR2(500 ),
  POSITION_TYPE           VARCHAR2(500 ),
  POSITION_SUB_TYPE_ID    VARCHAR2(500 ),
  POSITION_SUB_TYPE       VARCHAR2(500 ),
  POSITION_DISPLAY_ORDER  VARCHAR2(500 ),
  MAIN_TYPE_ID            VARCHAR2(500 ),
  MAIN_TYPE               VARCHAR2(500 )
);


Insert into DIM_UNRPNL_TYPE
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER)
 Values
   ('Physical - Open Sales', 'Physical', '1', 'Open Sales', '2');
Insert into DIM_UNRPNL_TYPE
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER)
 Values
   ('Derivatives - Future Buy', 'Derivatives', '2', 'Future Buy', '8');
Insert into DIM_UNRPNL_TYPE
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER)
 Values
   ('Derivatives - Future Sell', 'Derivatives', '2', 'Future Sell', '7');
Insert into DIM_UNRPNL_TYPE
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER)
 Values
   ('Physical - Inventory Purchase', 'Physical', '1', 'Inventory Purchase', '5');
Insert into DIM_UNRPNL_TYPE
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER)
 Values
   ('Physical - Shipped but title not transferred on Sales', 'Physical', '1', 'Shipped but title not transferred on Sales', '4');
Insert into DIM_UNRPNL_TYPE
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER)
 Values
   ('Physical - Open Purchase', 'Physical', '1', 'Open Purchase', '1');
Insert into DIM_UNRPNL_TYPE
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER)
 Values
   ('Physical - Shipped but title not transferred on Purchase', 'Physical', '1', 'Shipped but title not transferred on Purchase', '3');
Insert into DIM_UNRPNL_TYPE
   (POSITION_TYPE_ID, POSITION_TYPE, POSITION_SUB_TYPE_ID, POSITION_SUB_TYPE, POSITION_DISPLAY_ORDER)
 Values
   ('Physical - Inventory Sales', 'Physical', '1', 'Inventory Sales', '6');
COMMIT;
DROP TABLE DIM_TIME
/

CREATE TABLE DIM_TIME 
(
    DATE_ID                   DATE,
    DAY_OF_MONTH              VARCHAR2(20),
    MNTH_ID                   VARCHAR2(2000),
    MNTH_NM                   VARCHAR2(2000),
    QUARTER_DESC              VARCHAR2(20),
    YEAR                      VARCHAR2(4)
)
/

ALTER TABLE DIM_TIME ADD CONSTRAINT DIM_TIME_PK PRIMARY KEY (DATE_ID)
/

INSERT INTO DIM_TIME
SELECT DATE_VALUE DATE_ID,
       TO_NUMBER(TO_CHAR(DATE_VALUE,
                         'DD')) DAY_OF_MONTH,
       TRIM(TO_CHAR(DATE_VALUE,
                    'MM')) MNTH_ID,
       TRIM(TO_CHAR(DATE_VALUE,
                    'Mon')) MNTH_NM,
       'Quarter ' || TO_CHAR(DATE_VALUE,
                             'Q YYYY') QUARTER_DESC,
       TO_NUMBER(TO_CHAR(DATE_VALUE,
                         'YYYY')) YEAR
FROM   (SELECT TO_DATE('12/31/1999',
                       'MM/DD/YYYY') + N DATE_VALUE
        FROM   ( -- DATE SPECIFIED IS DAY BEFORE START DATE
                SELECT LEVEL N
                FROM   DUAL
                CONNECT BY LEVEL <= (TO_DATE('01/01/2021',
                                             'MM/DD/YYYY') -
                           TO_DATE('01/01/2000',
                                             'MM/DD/YYYY')) -- REPRESENTS NUMBER OF YEARS IN DAYS
                )
        UNION
        SELECT TO_DATE('01/01/1900',
                       'MM/DD/YYYY') DATE_VALUE
        FROM   DUAL -- INSERT LOW VALUE
        UNION
        SELECT TO_DATE('12/31/9999',
                       'MM/DD/YYYY') DATE_VALUE
        FROM   DUAL -- INSERT HIGH VALUE
        );
commit;        
ALTER TABLE dim_time ADD DATE_NM VARCHAR2(11);
UPDATE DIM_TIME SET DATE_NM = TO_CHAR(DATE_ID,'dd-Mon-yyyy')
/
UPDATE AMC_APP_MENU_CONFIGURATION AMC SET AMC.MENU_DISPLAY_NAME ='PNL Manager'
where AMC.MENU_ID ='BI-7';

CREATE INDEX IDX_PQCA2 ON PQCA_PQ_CHEMICAL_ATTRIBUTES
(ASM_ID, IS_ACTIVE, IS_DEDUCTIBLE);

CREATE TABLE PDCVM_PDC_VALUATION_MONTH
(PROMPT_DELIVERY_CALENDAR_ID VARCHAR2(15),
SHIPMENT_MONTH_YEAR DATE,
VAL_MONTH_YEAR_PREVIOUS DATE,
VAL_MONTH_YEAR_CLOSEST DATE,
VAL_MONTH_YEAR_NEXT DATE);

CREATE INDEX IDX_PDCVM1 ON PDCVM_PDC_VALUATION_MONTH(PROMPT_DELIVERY_CALENDAR_ID,SHIPMENT_MONTH_YEAR);

create OR REPLACE  view v_qat_quality_exch_data as SELECT 
       qat.quality_id,
       pdd.derivative_def_id derivative_def_id,
       pdd.derivative_def_name derivative_def_name,
       emt.exchange_id exchange_id,
       emt.exchange_name,
       dim.instrument_id,
       dim.instrument_name
FROM   qat_quality_attributes     qat,
       pdd_product_derivative_def pdd,
       pdtm_product_type_master   pdtm,
       pdm_productmaster          pdm,
       dim_der_instrument_master  dim,
       irm_instrument_type_master irm,
       emt_exchangemaster         emt
WHERE  qat.product_id = pdd.product_id
AND    qat.instrument_id = pdd.derivative_def_id
AND    pdd.derivative_def_id = dim.product_derivative_id
AND    qat.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdtm.product_type_name = 'Standard'
AND    dim.instrument_type_id = irm.instrument_type_id
AND    irm.instrument_type = 'Future'
AND    pdd.exchange_id = emt.exchange_id
AND    qat.is_active = 'Y'
AND    qat.is_deleted = 'N'
AND    pdd.is_active = 'Y'
AND    pdd.is_deleted = 'N'
AND    dim.is_active = 'Y'
AND    dim.is_deleted = 'N'
AND    irm.is_active = 'Y'
AND    irm.is_deleted = 'N'
AND    qat.eval_basis = 'DIFFERENTIAL'
UNION ALL
SELECT qat.quality_id,
       NULL derivative_def_id,
       NULL derivative_def_name,
       NULL exchange_id,
       NULL exchange_name,
       NULL instrument_id,
       NULL instrument_name
FROM   qat_quality_attributes     qat,
       pdm_productmaster          pdm,
       pdtm_product_type_master   pdtm
WHERE  qat.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdtm.product_type_name = 'Standard'
AND    qat.is_active = 'Y'
AND    qat.is_deleted = 'N'
AND    pdm.is_active = 'Y'
AND    pdm.is_deleted = 'N'
AND    qat.eval_basis = 'FIXED';
/
CREATE OR REPLACE VIEW V_QAT_QUALITY_VALUATION_CONC as 
SELECT --cpm.corporate_id,
       qat.quality_id,
       qat.quality_name,
       pdd.derivative_def_id derivative_def_id,
       pdd.derivative_def_name derivative_def_name,
       emt.exchange_id exchange_id,
       emt.exchange_name,
       dim.instrument_id,
       dim.instrument_name
FROM   qat_quality_attributes     qat,
       pdd_product_derivative_def pdd,
       pdtm_product_type_master   pdtm,
       pdm_productmaster          pdm,
       dim_der_instrument_master  dim,
       irm_instrument_type_master irm,
       cpm_corporateproductmaster cpm,
       emt_exchangemaster         emt
WHERE  qat.product_id = pdd.product_id
AND    qat.instrument_id = pdd.derivative_def_id
AND    pdd.derivative_def_id = dim.product_derivative_id
AND    qat.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdtm.product_type_name = 'Composite'
AND    pdd.product_id = cpm.product_id
AND    dim.instrument_type_id = irm.instrument_type_id
AND    irm.instrument_type = 'Future'
AND    pdd.exchange_id = emt.exchange_id
AND    qat.is_active = 'Y'
AND    qat.is_deleted = 'N'
AND    pdd.is_active = 'Y'
AND    pdd.is_deleted = 'N'
AND    dim.is_active = 'Y'
AND    dim.is_deleted = 'N'
AND    irm.is_active = 'Y'
AND    irm.is_deleted = 'N'
AND    cpm.is_active = 'Y'
AND    cpm.is_deleted = 'N'
AND    qat.eval_basis = 'DIFFERENTIAL'
AND    pdm.valuation_against_underlying = 'N'
UNION ALL
SELECT --cpm.corporate_id,
       qat.quality_id,
       qat.quality_name,
       NULL derivative_def_id,
       NULL derivative_def_name,
       NULL exchange_id,
       NULL exchange_name,
       NULL instrument_id,
       NULL instrument_name
FROM   qat_quality_attributes     qat,
       pdm_productmaster          pdm,
       pdtm_product_type_master   pdtm
WHERE  qat.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdtm.product_type_name = 'Composite'
AND    qat.is_active = 'Y'
AND    qat.is_deleted = 'N'
AND    pdm.is_active = 'Y'
AND    pdm.is_deleted = 'N'
AND    nvl(qat.eval_basis,'FIXED') = 'FIXED'
AND    pdm.valuation_against_underlying = 'Y';
/
CREATE OR REPLACE VIEW v_stock_position_assay_id (internal_grd_ref_no,
                                                        ash_id,
                                                        assay_type,
                                                        activity_date
                                                       )
AS
   SELECT internal_grd_ref_no, ash_id, assay_type, activity_date
     FROM (SELECT sam.internal_grd_ref_no, ash.ash_id, ash.assay_type,
                  ash.activity_date,
                  ROW_NUMBER () OVER (PARTITION BY sam.internal_grd_ref_no ORDER BY DECODE
                                                         (ash.assay_type,
                                                          'Contractual Assay', 1,
                                                          2
                                                         ) DESC,
                   ash.activity_date DESC,
                   ash.ash_id) sno
             FROM sam_stock_assay_mapping sam, ash_assay_header ash
            WHERE sam.is_active = 'Y'
              AND sam.ash_id = ash.ash_id
              AND ash.assay_type IN
                     ('Contractual Assay', 'Weighted Avg Position Assay',
                      'Position Assay')
              AND sam.internal_grd_ref_no IS NOT NULL
              AND ash.is_active = 'Y'
           UNION ALL
           SELECT sam.internal_dgrd_ref_no internal_grd_ref_no, ash.ash_id,
                  ash.assay_type, ash.activity_date,
                  ROW_NUMBER () OVER (PARTITION BY sam.internal_dgrd_ref_no ORDER BY DECODE
                                                         (ash.assay_type,
                                                          'Contractual Assay', 1,
                                                          2
                                                         ) DESC,
                   ash.activity_date DESC,
                   ash.ash_id) sno
             FROM sam_stock_assay_mapping sam, ash_assay_header ash
            WHERE sam.is_active = 'Y'
              AND sam.ash_id = ash.ash_id
              AND ash.assay_type IN
                     ('Contractual Assay', 'Weighted Avg Position Assay',
                      'Position Assay')
              AND sam.internal_dgrd_ref_no IS NOT NULL
              AND ash.is_active = 'Y')
    WHERE sno = 1;
/
create or replace view v_ucm_conversion as 
SELECT ucm.from_qty_unit_id, 
                ucm.to_qty_unit_id, 
                qum_from.qty_unit qum_from_qty_unit, 
                qum_to.qty_unit   qum_to_qty_unit, 
                ucm.multiplication_factor 
         FROM   ucm_unit_conversion_master ucm, 
                qum_quantity_unit_master qum_to, 
                qum_quantity_unit_master qum_from 
         WHERE  ucm.from_qty_unit_id = qum_from.qty_unit_id 
                AND ucm.to_qty_unit_id = qum_to.qty_unit_id 
                AND ucm.is_active = 'Y' 
                AND qum_from.is_deleted = 'N' 
                AND qum_to.is_deleted = 'N';
/
/* Formatted on 2011/10/20 12:07 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_latest_options_quotes (dr_id,
                                                      corporate_id,
                                                      period_month,
                                                      period_year,
                                                      strike_price,
                                                      strike_price_unit_id,
                                                      trade_date,
                                                      created_date,
                                                      open_price,
                                                      ask_price,
                                                      bid_price,
                                                      closing_price,
                                                      gamma,
                                                      theta,
                                                      wega,
                                                      delta,
                                                      settlement_price,
                                                      price_unit_id,
                                                      price_string,
                                                      product_id,
                                                      contract_name
                                                     )
AS
   SELECT   drm.dr_id dr_id, dq.corporate_id, drm.period_month,
            drm.period_year, drm.strike_price, drm.strike_price_unit_id,
            dq.trade_date, dq.created_date, NULL open_price, NULL ask_price,
            NULL bid_price, NULL closing_price, dqd.gamma, dqd.theta,
            dqd.wega, dqd.delta, dqd.price settlement_price,
            dqd.price_unit_id,
               dqd.price
            || ' '
            || pkg_general.f_get_price_unit (dqd.price_unit_id) price_string,
            pdd.product_id, pdd.derivative_def_name contract_name
       FROM dqd_derivative_quote_detail dqd,
            dq_derivative_quotes dq,
            apm_available_price_master apm,
            drm_derivative_master drm,
            dim_der_instrument_master dim,
            pdd_product_derivative_def pdd,
            irm_instrument_type_master irm
      WHERE drm.dr_id = dqd.dr_id
        AND drm.dr_id = dqd.dr_id
        AND drm.instrument_id = dim.instrument_id
        AND dim.product_derivative_id = pdd.derivative_def_id
        AND dqd.dq_id = dq.dq_id
        AND dqd.available_price_id = apm.available_price_id
        AND dim.instrument_type_id = irm.instrument_type_id
        AND irm.instrument_type IN ('Option Put', 'Option Call')
        AND apm.available_price_name = 'Settlement'
        AND dq.created_date =
               (SELECT MAX (dq_sub.created_date) created_date
                  FROM dqd_derivative_quote_detail dqd_sub,
                       dq_derivative_quotes dq_sub,
                       drm_derivative_master drm_sub
                 WHERE dqd_sub.dq_id = dq_sub.dq_id
                   AND dqd_sub.dr_id = dqd.dr_id
                   AND dqd_sub.dr_id = drm_sub.dr_id
                   AND drm_sub.strike_price = drm.strike_price
                   AND drm_sub.strike_price_unit_id = drm.strike_price_unit_id
                   AND dq_sub.trade_date <= SYSDATE)
--GROUP BY DQD_SUB.DR_ID)
   ORDER BY dq.created_date DESC;
/
CREATE OR REPLACE VIEW v_deductible_value_by_ash_id (ash_id, typical)
AS
   SELECT   ash.ash_id, SUM (NVL (pqca.typical, 0)) typical
       FROM ash_assay_header ash,
            asm_assay_sublot_mapping asm,
            pqca_pq_chemical_attributes pqca
      WHERE ash.ash_id = asm.ash_id
        AND asm.asm_id = pqca.asm_id
        AND pqca.is_deductible = 'Y'
        AND pqca.is_active = 'Y'
   GROUP BY ash.ash_id;
/

CREATE OR REPLACE VIEW v_contract_shipment_month_year (      pcdi_id,
                                                             instrument_id,
                                                             internal_contract_ref_no,
                                                             internal_contract_item_ref_no,
                                                             basis_type,
                                                             transit_days,
                                                             contract_ref_no,
                                                             expected_delivery_month,
                                                             expected_delivery_year,
                                                             date_type,
                                                             ship_arrival_date,
                                                             ship_arrival_days,
                                                             expected_ship_arrival_date,
                                                             basis_month_year,
                                                             exch_valuation_month, 
                                                             exchange_id,
                                                             exchange_name, 
                                                             derivative_def_id,
                                                             derivative_def_name, 
                                                             instrument_name, 
                                                             delivery_calender_id
                                                            )
AS
   SELECT t.pcdi_id, t.instrument_id, t.internal_contract_ref_no,
          t.internal_contract_item_ref_no, t.basis_type, t.transit_days,
          t.contract_ref_no, t.expected_delivery_month,
          t.expected_delivery_year, t.date_type, t.ship_arrival_date,
          t.ship_arrival_days, t.expected_ship_arrival_date,
            (CASE
                WHEN t.ship_arrival_date = 'Start Date'
                   THEN TO_DATE (   '01-'
                                 || TO_CHAR (t.expected_ship_arrival_date,
                                             'Mon-yyyy'
                                            )
                                )
                WHEN t.ship_arrival_date = 'End Date'
                   THEN LAST_DAY (t.expected_ship_arrival_date)
                ELSE (  TO_DATE (   '01-'
                                 || TO_CHAR (t.expected_ship_arrival_date,
                                             'Mon-yyyy'
                                            )
                                )
                      + TRUNC
                            (  (  LAST_DAY (t.expected_ship_arrival_date)
                                - TO_DATE
                                       (   '01-'
                                        || TO_CHAR
                                                (t.expected_ship_arrival_date,
                                                 'Mon-yyyy'
                                                )
                                       )
                               )
                             / 2
                            )
                     )
             END
            )
          + t.ship_arrival_days basis_month_year,
          t.exch_valuation_month, t.exchange_id,
                  t.exchange_name, t.derivative_def_id,
                  t.derivative_def_name, 
                  t.instrument_name, t.delivery_calender_id
     FROM (SELECT pcdi.pcdi_id, pcdi.internal_contract_ref_no,
                  pci.internal_contract_item_ref_no, pcdi.basis_type,
                  NVL (pcdi.transit_days, 0) transit_days,
                  pcm.contract_ref_no, pci.expected_delivery_month,
                  pci.expected_delivery_year, qat.date_type,
                  qat.ship_arrival_date, qat.instrument_id,
                  NVL (qat.ship_arrival_days, 0) ship_arrival_days,
                  (CASE
                      WHEN qat.date_type = 'Shipment Date'
                         THEN (CASE
                                  WHEN pcdi.basis_type = 'Shipment'
                                     THEN LAST_DAY
                                               (   '01-'
                                                || pci.expected_delivery_month
                                                || '-'
                                                || pci.expected_delivery_year
                                               )
                                  ELSE   LAST_DAY
                                               (   '01-'
                                                || pci.expected_delivery_month
                                                || '-'
                                                || pci.expected_delivery_year
                                               )
                                       - NVL (pcdi.transit_days, 0)
                               END
                              )
                      ELSE (CASE
                               WHEN pcdi.basis_type = 'Shipment'
                                  THEN   LAST_DAY
                                               (   '01-'
                                                || pci.expected_delivery_month
                                                || '-'
                                                || pci.expected_delivery_year
                                               )
                                       + NVL (pcdi.transit_days, 0)
                               ELSE LAST_DAY (   '01-'
                                              || pci.expected_delivery_month
                                              || '-'
                                              || pci.expected_delivery_year
                                             )
                            END
                           )
                   END
                  ) expected_ship_arrival_date,
                  qat.exch_valuation_month, emt.exchange_id,
                  emt.exchange_name, pdd.derivative_def_id,
                  pdd.derivative_def_name, 
                  dim.instrument_name, dim.delivery_calender_id
             FROM pcdi_pc_delivery_item pcdi,
                  pci_physical_contract_item pci,
                  pcm_physical_contract_main pcm,
                  pcpq_pc_product_quality pcpq,
                  qat_quality_attributes qat,
                  v_qat_quality_exch_data v_qat,
                  dim_der_instrument_master dim,
                  pdd_product_derivative_def pdd,
                  emt_exchangemaster emt,
                  irm_instrument_type_master irm
            WHERE pcdi.pcdi_id = pci.pcdi_id
              AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
              AND pcm.contract_status = 'In Position'
              AND pcm.contract_type = 'BASEMETAL'
              AND pci.item_qty > 0
              AND pci.pcpq_id = pcpq.pcpq_id
              AND pcpq.quality_template_id = qat.quality_id
              AND pcdi.is_active = 'Y'
              AND pci.is_active = 'Y'
              AND pcm.is_active = 'Y'
              AND qat.quality_id = v_qat.quality_id
              AND v_qat.derivative_def_id = pdd.derivative_def_id(+)
              AND v_qat.exchange_id = emt.exchange_id(+)
              AND v_qat.instrument_id = dim.instrument_id(+)
              AND dim.instrument_type_id = irm.instrument_type_id(+)
              AND 'Future' = irm.instrument_type(+)) t;
/
CREATE OR REPLACE FORCE VIEW v_conc_shipment_month_year 
AS
SELECT t.pcdi_id,
       t.instrument_id,
       t.internal_contract_ref_no,
       t.internal_contract_item_ref_no,
       t.basis_type,
       t.transit_days,
       t.contract_ref_no,
       t.expected_delivery_month,
       t.expected_delivery_year,
       t.date_type,
       t.ship_arrival_date,
       t.ship_arrival_days,
       t.expected_ship_arrival_date,
       (CASE
           WHEN t.ship_arrival_date = 'Start Date' THEN
            to_date('01-' || to_char(t.expected_ship_arrival_date, 'Mon-yyyy'))
           WHEN t.ship_arrival_date = 'End Date' THEN
            last_day(t.expected_ship_arrival_date)
           ELSE
            (to_date('01-' || to_char(t.expected_ship_arrival_date, 'Mon-yyyy')) +
            trunc((last_day(t.expected_ship_arrival_date) -
                   to_date('01-' ||
                            to_char(t.expected_ship_arrival_date, 'Mon-yyyy'))) / 2))
       END) + t.ship_arrival_days basis_month_year,
       t.exch_valuation_month,
       t.exchange_id,
       t.exchange_name,
       t.derivative_def_id,
       t.derivative_def_name,
       t.instrument_name,
       t.delivery_calender_id
FROM   (SELECT pcdi.pcdi_id,
               pcdi.internal_contract_ref_no,
               pci.internal_contract_item_ref_no,
               pcdi.basis_type,
               nvl(pcdi.transit_days, 0) transit_days,
               pcm.contract_ref_no,
               pci.expected_delivery_month,
               pci.expected_delivery_year,
               qat.date_type,
               qat.ship_arrival_date,
               nvl(qat.ship_arrival_days, 0) ship_arrival_days,
               (CASE
                    WHEN qat.date_type = 'Shipment Date' THEN
                     (CASE
                    WHEN pcdi.basis_type = 'Shipment' THEN
                     last_day('01-' || pci.expected_delivery_month || '-' ||
                              pci.expected_delivery_year)
                    ELSE
                     last_day('01-' || pci.expected_delivery_month || '-' ||
                              pci.expected_delivery_year) -
                     nvl(pcdi.transit_days, 0)
                END) ELSE(CASE
                   WHEN pcdi.basis_type = 'Shipment' THEN
                    last_day('01-' || pci.expected_delivery_month || '-' ||
                             pci.expected_delivery_year) +
                    nvl(pcdi.transit_days, 0)
                   ELSE
                    last_day('01-' || pci.expected_delivery_month || '-' ||
                             pci.expected_delivery_year)
               END) END) expected_ship_arrival_date,
               qat.exch_valuation_month,
               emt.exchange_id,
               emt.exchange_name,
               pdd.derivative_def_id,
               pdd.derivative_def_name,
               dim.instrument_id,
               dim.instrument_name,
               dim.delivery_calender_id
        FROM   pcdi_pc_delivery_item        pcdi,
               pci_physical_contract_item   pci,
               pcm_physical_contract_main   pcm,
               pcpq_pc_product_quality      pcpq,
               qat_quality_attributes       qat,
               v_qat_quality_valuation_conc v_qat,
               dim_der_instrument_master    dim,
               pdd_product_derivative_def   pdd,
               emt_exchangemaster           emt,
               irm_instrument_type_master irm
        WHERE  pcdi.pcdi_id = pci.pcdi_id
        AND    pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND    pcm.contract_status = 'In Position'
        AND    pcm.contract_type = 'CONCENTRATES'
        AND    pci.item_qty > 0
        AND    pci.pcpq_id = pcpq.pcpq_id
        AND    pcpq.quality_template_id = qat.quality_id
        AND    pcdi.is_active = 'Y'
        AND    pci.is_active = 'Y'
        AND    pcm.is_active = 'Y'
        AND    qat.quality_id = v_qat.quality_id
        AND    v_qat.derivative_def_id = pdd.derivative_def_id(+)
        AND    v_qat.exchange_id = emt.exchange_id(+)
        AND    v_qat.instrument_id = dim.instrument_id(+)
        and    dim.instrument_type_id = irm.instrument_type_id(+)
        AND   'Future' = irm.instrument_type(+)
        ) t;
/

CREATE OR REPLACE VIEW v_pci_pcdi_details (pcdi_id,
                                                 internal_contract_item_ref_no,
                                                 internal_contract_ref_no,
                                                 delivery_item_no,
                                                 purchase_sales,
                                                 contract_ref_no,
                                                 del_distribution_item_no,
                                                 inco_term_id,
                                                 country_id,
                                                 city_id,
                                                 strategy_id,
                                                 product_id,
                                                 profit_center_id,
                                                 quality_template_id,
                                                 assay_header_id,
                                                 trader_id,
                                                 cp_id,
                                                 product_group_type,
                                                 payment_term_id,
                                                 payment_due_date,
                                                 incoterm_id,
                                                 incoterm,
                                                 delivery_from_date,
                                                 delivery_to_date,
                                                 expected_delivery_month,
                                                 expected_delivery_year,
                                                 invoice_currency_id,
                                                 issue_date,
                                                 cp_contract_ref_no,
                                                 m2m_country_id,
                                                 m2m_city_id,
                                                 pcdb_id,
                                                 delivery_period_type,
                                                 is_called_off,
                                                 pcpq_id,
                                                 item_price_type,
												 is_tolling_contract
                                                )
AS
   SELECT pcdi.pcdi_id, pci.internal_contract_item_ref_no,
          pcdi.internal_contract_ref_no, pcdi.delivery_item_no,
          pcm.purchase_sales, pcm.contract_ref_no,
          pci.del_distribution_item_no, pcdb.inco_term_id, pcdb.country_id,
          pcdb.city_id, pcpd.strategy_id, pcpd.product_id,
          pcpd.profit_center_id, pcpq.quality_template_id,
          pcpq.assay_header_id, pcm.trader_id, pcm.cp_id,
          pcm.product_group_type, pcm.payment_term_id, pcdi.payment_due_date,
          itm.incoterm_id, itm.incoterm, pci.delivery_from_date,
          pci.delivery_to_date, pci.expected_delivery_month,
          pci.expected_delivery_year, pcm.invoice_currency_id, pcm.issue_date,
          pcm.cp_contract_ref_no, pci.m2m_country_id, pci.m2m_city_id, pcdb.pcdb_id,
          pci.delivery_period_type, pci.is_called_off, pcpq.pcpq_id, pcdi.item_price_type,
		  NVL (pcm.is_tolling_contract, 'N') is_tolling_contract
     FROM pci_physical_contract_item pci,
          pcdi_pc_delivery_item pcdi,
          pcdb_pc_delivery_basis pcdb,
          pcm_physical_contract_main pcm,
          pcpd_pc_product_definition pcpd,
          pcpq_pc_product_quality pcpq,
          itm_incoterm_master itm
    WHERE pci.pcdi_id = pcdi.pcdi_id
      AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcdi.internal_contract_ref_no = pcdb.internal_contract_ref_no
      AND pci.pcdb_id = pcdb.pcdb_id
      AND pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pcdb.inco_term_id = itm.incoterm_id(+)
      AND pci.is_active = 'Y'
      AND pcdi.is_active = 'Y'
      AND pcm.contract_status <> 'Cancelled'
      AND pcm.is_active = 'Y';
/
CREATE OR REPLACE VIEW V_CONC_POSITION AS 
--
-- Concentrates Position
--
-- Open Contracts
--
SELECT 
       'Composite' product_type,
       'Concentrates Open Contracts' section_name,
       pcm.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       css.strategy_id,
       css.strategy_name,
       pdm.product_id,
       pdm.product_desc,
       nvl(qat.product_origin_id, 'NA') origin_id,
       nvl(orm.origin_name, 'NA') origin_name,
       qat.quality_id,
       qat.quality_name,
       case when pcm.purchase_sales='P' then 'Physical - Open Purchase'  else 'Physical - Open Sales' end    AS position_type_id,
       'Physical' AS position_type,
       case when pcm.purchase_sales='P' then 'Open Purchase'  else 'Open Sales' end  AS position_sub_type,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no contract_ref_no,
       nvl(pcm.cp_contract_ref_no, 'NA') cp_contract_ref_no,
       pcm.issue_date,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker_name,
       itm.incoterm_id,
       itm.incoterm,
       pym.payment_term_id,
       pym.payment_term,
       CASE WHEN itm.location_field = 'ORIGINATION' THEN pcdb.country_id ELSE 'NA'  END origination_country_id,
       CASE WHEN itm.location_field = 'ORIGINATION' THEN cym_pcdb.country_name  ELSE 'NA' END origination_country,
       CASE WHEN itm.location_field = 'ORIGINATION' THEN cim_pcdb.city_id ELSE 'NA' END origination_city_id,
       CASE WHEN itm.location_field = 'ORIGINATION' THEN cim_pcdb.city_name ELSE 'NA' END origination_city,
       nvl(pcdi.item_price_type, 'NA') price_type_name,
       pcm.invoice_currency_id pay_in_cur_id,
       cm_invoice_cur.cur_code pay_in_cur_code, 
       nvl(v_ship.derivative_def_id,'NA') derivative_def_id,
       nvl(v_ship.derivative_def_name,'NA') derivative_def_name,
       nvl(v_ship.exchange_id,'NA') exchange_id,
       nvl(v_ship.exchange_name,'NA') exchange_name,
       nvl(v_ship.instrument_id,'NA') instrument_id,
       nvl(v_ship.instrument_name,'NA') instrument_name,
       'NA' item_price_string,
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.country_id ELSE 'NA' END dest_country_id,
       CASE WHEN itm.location_field = 'DESTINATION' THEN cym_pcdb.country_name ELSE 'NA' END dest_country_name,
       CASE WHEN itm.location_field = 'DESTINATION' THEN cim_pcdb.city_id ELSE 'NA' END dest_city_id,
       CASE WHEN itm.location_field = 'DESTINATION' THEN cim_pcdb.city_name ELSE 'NA' END dest_city_name,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year period_month_year,
       CASE WHEN pci.delivery_period_type = 'Date' AND pci.is_called_off = 'Y' THEN pci.delivery_from_date
           ELSE to_date('01-' || pci.expected_delivery_month || '-' || pci.expected_delivery_year,'dd-Mon-yyyy')
       END DELIVERY_FROM_DATE,
       CASE WHEN pci.delivery_period_type = 'Date' AND pci.is_called_off = 'Y' THEN pci.delivery_to_date
           ELSE to_date('01-' || pci.expected_delivery_month || '-' ||pci.expected_delivery_year, 'dd-Mon-yyyy')
       END DELIVERY_TO_DATE,
        to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),'Mon-yyyy') valuation_month,
       pci.m2m_city_id valuation_city_id,
       cim_m2m_city.city_name valuation_city_name,
       pci.m2m_country_id valuation_country_id,
       cym_m2m_country.country_name valuation_country_name,
       (CASE WHEN pcpq.unit_of_measure = 'Dry' THEN ciqs.open_qty ELSE ciqs.open_qty * (1 - (nvl(vsh.typical, 1) / 100)) END) * 
       ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (CASE WHEN pcpq.unit_of_measure = 'Dry' THEN ciqs.open_qty ELSE ciqs.open_qty * (1 - (nvl(vsh.typical, 1) / 100)) END) qty_in_ctract_unit,
       qum_ciqs.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pcm.invoice_currency_id invoice_cur_id,
       cm_invoice_cur.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       (CASE WHEN pcpq.unit_of_measure = 'Dry' THEN ciqs.open_qty ELSE ciqs.open_qty * (1 - (nvl(vsh.typical, 1) / 100)) END) * 
       ucm_base.multiplication_factor qty_in_base_unit,
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.country_id ELSE 'NA' END || ' - ' || CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.city_id
           ELSE 'NA' END comb_destination_id,
       CASE WHEN itm.location_field = 'ORIGINATION' THEN pcdb.country_id ELSE 'NA' END || ' - ' ||  CASE WHEN itm.location_field = 'ORIGINATION' THEN pcdb.city_id
           ELSE 'NA'  END comb_origination_id,
       pci.m2m_country_id || ' - ' || pci.m2m_city_id comb_valuation_loc_id
FROM   pci_physical_contract_item    pci,
       pcm_physical_contract_main    pcm,
       pcdi_pc_delivery_item         pcdi,
       ciqs_contract_item_qty_status ciqs,
       pcpd_pc_product_definition    pcpd,
       pcpq_pc_product_quality       pcpq,
       pcdb_pc_delivery_basis        pcdb,
       v_conc_shipment_month_year    v_ship,
       ak_corporate                  akc,
       cpc_corporate_profit_center   cpc,
       blm_business_line_master      blm,
       css_corporate_strategy_setup  css,
       pdm_productmaster             pdm,
       qat_quality_attributes        qat,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       itm_incoterm_master           itm,
       pym_payment_terms_master      pym,
       cm_currency_master            cm_base_cur,
       cm_currency_master            cm_invoice_cur,
       cim_citymaster                cim_m2m_city,
       cym_countrymaster             cym_m2m_country,
       phd_profileheaderdetails      phd_contract_cp,
       pom_product_origin_master     pom,
       orm_origin_master             orm,
       cym_countrymaster             cym_pcdb,
       cim_citymaster                cim_pcdb,
       qum_quantity_unit_master      qum_ciqs,
       gcd_groupcorporatedetails     gcd,
       qum_quantity_unit_master      qum_gcd,
       ucm_unit_conversion_master    ucm,
       v_ucm_conversion              ucm_base,
       v_deductible_value_by_ash_id  vsh,
       pdcvm_pdc_valuation_month pdcvm
WHERE  pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdi.pcdi_id = pci.pcdi_id
AND    pcm.contract_status = 'In Position'
AND    pcm.contract_type = 'CONCENTRATES'
AND    pci.internal_contract_item_ref_no = ciqs.internal_contract_item_ref_no
AND    pci.is_active = 'Y'
AND    pcdi.is_active = 'Y'
AND    ciqs.is_active = 'Y'
AND    ciqs.open_qty > 0
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.is_active = 'Y'
AND    pci.pcpq_id = pcpq.pcpq_id
AND    pcpq.is_active = 'Y'
AND    pci.pcdb_id = pcdb.pcdb_id
AND    pcdb.is_active = 'Y'
AND    pci.internal_contract_item_ref_no(+) = v_ship.internal_contract_item_ref_no
AND    pci.pcdi_id = v_ship.pcdi_id
AND    pcm.corporate_id = akc.corporate_id
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    cpc.business_line_id = blm.business_line_id
AND    pcpd.strategy_id = css.strategy_id
AND    pcpd.product_id = pdm.product_id
AND    pcpq.quality_template_id = qat.quality_id
AND    pcm.trader_id = akcu.user_id
AND    akcu.gabid = gab.gabid
AND    pcdb.inco_term_id = itm.incoterm_id
AND    pcm.payment_term_id = pym.payment_term_id
AND    cm_base_cur.cur_id = akc.base_cur_id
AND    akc.base_cur_id = cm_invoice_cur.cur_id
AND    pci.m2m_city_id = cim_m2m_city.city_id
AND    pci.m2m_country_id = cym_m2m_country.country_id
AND    pcm.cp_id = phd_contract_cp.profileid
AND    qat.product_origin_id = pom.product_origin_id(+)
and    pcpq.assay_header_id = vsh.ash_id(+)
AND    pom.origin_id = orm.origin_id(+)
AND    cym_pcdb.country_id = pcdb.country_id
AND    cim_pcdb.city_id = pcdb.city_id
AND    qum_ciqs.qty_unit_id = ciqs.item_qty_unit_id
AND    akc.groupid = gcd.groupid
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    ucm.from_qty_unit_id = ciqs.item_qty_unit_id
AND    ucm.to_qty_unit_id = gcd.group_qty_unit_id
AND    ciqs.item_qty_unit_id = ucm_base.from_qty_unit_id
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id
and    pcpq.quality_template_id = qat.quality_id
and    v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
and    v_ship.basis_month_year = pdcvm.shipment_month_year(+)

UNION ALL
--
-- 2. Shipped But Not TT for Purchase GMRs
--
SELECT 'Composite'  Product_Type,
       'Concentrates Shipped But Not TT for Purchase GMRs' section_name,
       gmr.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       grd.product_id product_id,
       pdm.product_desc product_desc,
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
       case when pci.purchase_sales='P' then 'Physical - Open Purchase'
       else 'Physical - Open Sales' end  position_type_id,
       'Physical' position_type,
       case when pci.purchase_sales='P' then 'Open Purchase'
       else 'Open Sales' end  position_sub_type,
       CASE WHEN pci.contract_ref_no IS NOT NULL THEN
            gmr.gmr_ref_no || ',' || pci.contract_ref_no || ',' || pci.del_distribution_item_no
           ELSE gmr.gmr_ref_no
       END contract_ref_no,
       nvl(pci.cp_contract_ref_no, 'NA') external_reference_no,
       gmr.eff_date issue_date,
       pci.cp_id counter_party_id,
       phd_pcm_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_name,
       'NA' broker_profile_id,
       'NA' broker_name,
       pci.incoterm_id incoterm_id,
       itm.incoterm incoterm,
       pci.payment_term_id payment_term_id,
       pym.payment_term payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       nvl(pcdi.item_price_type, 'NA') price_type_name,
       pci.invoice_currency_id pay_in_cur_id,
       cm_invoice_currency.cur_code pay_in_cur_code,
       nvl(v_ship.derivative_def_id, 'NA') derivative_def_id,
       nvl(v_ship.derivative_def_name, 'NA') derivative_def_name,
       nvl(v_ship.exchange_id, 'NA') exchange_id,
       nvl(v_ship.exchange_name, 'NA') exchange_name,
       nvl(v_ship.instrument_id, 'NA') instrument_id,
       nvl(v_ship.instrument_name, 'NA') instrument_name,
       'NA' item_price_string, -- do not need for GMR and Stocks
       nvl(cym_gmr_dest_country.country_id,'NA') dest_country_id,
       nvl(cym_gmr_dest_country.country_name,'NA') dest_country_name,
       nvl(cim_gmr_dest_city.city_id,'NA') dest_city_id,
       nvl(cim_gmr_dest_city.city_name,'NA') dest_city_name,
       to_char(v_ship.basis_month_year, 'Mon-yyyy') period_month_year,
       CASE WHEN pci.delivery_period_type = 'Date' AND pci.is_called_off = 'Y' THEN pci.delivery_from_date
           ELSE to_date('01-' || pci.expected_delivery_month || '-' || pci.expected_delivery_year,'dd-Mon-yyyy')
       END delivery_from_date,
       CASE WHEN pci.delivery_period_type = 'Date' AND pci.is_called_off = 'Y' THEN pci.delivery_from_date
           ELSE to_date('01-' || pci.expected_delivery_month || '-' ||pci.expected_delivery_year,'dd-Mon-yyyy')
       END,
         to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),
               'Mon-yyyy') valuation_month,
       (CASE WHEN grd.is_afloat = 'Y' THEN cim_gmr.city_id
           ELSE cim_sld.city_id
       END) valuation_city_id,
       (CASE WHEN grd.is_afloat = 'Y' THEN cim_gmr.city_id
           ELSE cim_sld.city_name
       END) valuation_city_name,
       CASE WHEN grd.is_afloat = 'Y' THEN cym_gmr.country_id
           ELSE cym_sld.country_id
       END valuation_country_id,
       CASE WHEN grd.is_afloat = 'Y' THEN cym_gmr.country_id
           ELSE cym_sld.country_name
       END valuation_country_name,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0)) -
       nvl(grd.title_transfer_out_qty, 0)) *
       (1 - (nvl(vdc.typical, 1) / 100)) * ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0)) - nvl(grd.title_transfer_out_qty, 0)) *
       (1 - (nvl(vdc.typical, 1) / 100)) qty_in_ctract_unit,
       grd.qty_unit_id ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0)) - nvl(grd.title_transfer_out_qty, 0)) *
       (1 - (nvl(vdc.typical, 1) / 100)) * ucm_base.multiplication_factor qty_in_base_unit,
       nvl(cym_gmr_dest_country.country_id,'NA') || ' - ' || nvl(cim_gmr_dest_city.city_id,'NA') comb_destination_id,
       'NA-NA' comb_origination_id,
       nvl(CASE WHEN grd.is_afloat = 'Y' THEN cym_gmr.country_id
           ELSE cym_sld.country_id
       END,'NA') || ' - ' || 
       nvl(CASE WHEN grd.is_afloat = 'Y' THEN cim_gmr.city_id
           ELSE cim_sld.city_id
       END,'NA') comb_valuation_loc_id
FROM   grd_goods_record_detail        grd,
       gmr_goods_movement_record      gmr,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       v_pci_pcdi_details             pci,
       pdm_productmaster              pdm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       itm_incoterm_master            itm,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       gab_globaladdressbook          gab,
       phd_profileheaderdetails       phd_pcm_cp,
       pym_payment_terms_master       pym,
       cm_currency_master             cm_invoice_currency,
       cim_citymaster                 cim_gmr_dest_city,
       cym_countrymaster              cym_gmr_dest_country,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       cm_currency_master             cm_base_currency,
       pcdi_pc_delivery_item          pcdi,
       v_conc_shipment_month_year v_ship,
       v_ucm_conversion               ucm_base,
       v_stock_position_assay_id    vsp,
       v_deductible_value_by_ash_id vdc,
       ak_corporate_user aku,
       pdcvm_pdc_valuation_month pdcvm,
       qat_quality_attributes qat
WHERE  grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    grd.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdm.base_quantity_unit = qum.qty_unit_id
AND    grd.shed_id = sld.storage_loc_id(+)
AND    sld.city_id = cim_sld.city_id(+)
AND    gmr.discharge_city_id = cim_gmr.city_id(+)
AND    cim_sld.country_id = cym_sld.country_id(+)
AND    cim_gmr.country_id = cym_gmr.country_id(+)
AND    grd.quality_id = qat.quality_id(+)
AND    gmr.corporate_id = akc.corporate_id
AND    akc.groupid = gcd.groupid
AND    grd.is_deleted = 'N'
AND    grd.status = 'Active'
AND    grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
AND    pci.inco_term_id = itm.incoterm_id(+)
AND    pci.strategy_id = css.strategy_id(+)
AND    pci.profit_center_id = cpc.profit_center_id(+)
AND    cpc.business_line_id = blm.business_line_id(+)
AND    (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) - nvl(grd.title_transfer_out_qty, 0)) > 0
AND    gmr.created_by = aku.user_id
and    aku.gabid =  gab.gabid(+)
AND    pdtm.product_type_name = 'Composite'
AND    pci.cp_id = phd_pcm_cp.profileid(+)
AND    pci.payment_term_id = pym.payment_term_id(+)
AND    nvl(gmr.inventory_status,'NA') = 'In'
AND    pci.invoice_currency_id = cm_invoice_currency.cur_id(+) 
AND    cym_gmr_dest_country.country_id(+) = gmr.destination_country_id
AND    cim_gmr_dest_city.city_id(+) = gmr.destination_city_id
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    grd.qty_unit_id = ucm.from_qty_unit_id
AND    gcd.group_qty_unit_id = ucm.to_qty_unit_id
AND    cm_base_currency.cur_id = akc.base_cur_id
AND    pci.pcdi_id = pcdi.pcdi_id
AND    pcdi.internal_contract_ref_no = pci.internal_contract_ref_no
AND    pci.pcdi_id = v_ship.pcdi_id(+)
AND    pci.internal_contract_item_ref_no = v_ship.internal_contract_item_ref_no(+)
AND    grd.qty_unit_id = ucm_base.from_qty_unit_id
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id
AND    grd.internal_grd_ref_no = vsp.internal_grd_ref_no
AND    vsp.ash_id = vdc.ash_id(+)
and v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
and v_ship.basis_month_year = pdcvm.shipment_month_year(+)
--
-- 3. Shipped But Not TT Sales GMRs
--
UNION ALL
SELECT 'Composite'  Product_Type,
       'Concentrates Shipped But Not TT for Sales GMRs' section_name,
       akc.corporate_id                       corporate_id, 
       akc.corporate_name                     corporate_name, 
       blm.business_line_id                   business_line_id, 
       blm.business_line_name                 business_line_name, 
       cpc.profit_center_id                   profit_center_id, 
       cpc.profit_center_short_name           profit_center_short_name, 
       cpc.profit_center_name                 profit_center_name, 
       css.strategy_id                        strategy_id, 
       css.strategy_name                      strategy_name, 
       pdm.product_id                         product_id, 
       pdm.product_desc                       product_desc, 
       'NA'                                   origin_id, 
       'NA'                                   origin_name, 
       qat.quality_id                         quality_id, 
       qat.quality_name                       quality_name, 
       'Physical - Open Sales'               position_type_id, 
       'Physical'                             position_type, 
       'Open Sales'                           position_sub_type, 
       CASE WHEN pci.contract_ref_no IS NOT NULL THEN
       gmr.gmr_ref_no ||',' || pci.contract_ref_no ||',' || pci.del_distribution_item_no               
       ELSE gmr.gmr_ref_no end contract_ref_no, 
       nvl(pci.cp_contract_ref_no,'NA')                 external_reference_no, 
       pci.issue_date                         issue_date, 
       pci.cp_id                              counter_party_id, 
       phd_pcm_cp.companyname                 counter_party_name, 
       gab.gabid                              trader_user_id, 
       gab.firstname || ' ' || gab.lastname   trader_name, 
       'NA' broker_profile_id, 
       'NA' broker_name, 
       itm.incoterm_id 
       incoterm_id, 
       itm.incoterm incoterm, 
       pym.payment_term_id 
       payment_term_id, 
       pym.payment_term 
       payment_term, 
       'NA'                                             origination_country_id, 
       'NA'                                             origination_country, 
       'NA'                                             origination_city_id, 
       'NA'                                             origination_city, 
       'NA'                                             price_type_name, 
       cm_invoice_curreny.cur_id                        pay_in_cur_id, 
       cm_invoice_curreny.cur_code                      pay_in_cur_code, 
       nvl(v_ship.derivative_def_id,'NA')                  derivative_def_id, 
       nvl(v_ship.derivative_def_name,'NA')                derivative_def_name, 
       nvl(v_ship.exchange_id,'NA')                        exchange_id, 
       nvl(v_ship.exchange_name,'NA')                      exchange_name, 
       nvl(v_ship.instrument_id,'NA')                      instrument_id, 
       nvl(v_ship.instrument_name,'NA')                    instrument_name, 
       'NA'                          item_price_string, 
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.country_id 
         ELSE 'NA' 
       END destination_country_id, 
       CASE WHEN itm.location_field = 'DESTINATION' THEN cym_pcdb.country_name 
         ELSE 'NA' 
       END destination_country, 
       CASE WHEN itm.location_field = 'DESTINATION' THEN cim_pcdb.city_id 
         ELSE 'NA' 
       END destination_city_id, 
       CASE WHEN itm.location_field = 'DESTINATION' THEN cim_pcdb.city_name 
         ELSE 'NA' 
       END destination_city, 
       To_char (v_ship.basis_month_year, 'Mon-yyyy')   period_month_year, 
       CASE WHEN pci.delivery_period_type = 'Date' AND pci.is_called_off = 'Y' THEN pci.delivery_from_date
           ELSE to_date('01-' || pci.expected_delivery_month || '-' || pci.expected_delivery_year,'dd-Mon-yyyy')
       END   delivery_from_date, 
       CASE WHEN pci.delivery_period_type = 'Date' AND pci.is_called_off = 'Y' THEN pci.delivery_to_date
           ELSE to_date('01-' || pci.expected_delivery_month || '-' ||pci.expected_delivery_year,'dd-Mon-yyyy')
       END   delivery_to_date, 
       to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),'Mon-yyyy')  valuation_month, 
       cim_m2m.city_id        valuation_city_id, 
       cim_m2m.city_name        valuation_city_name, 
       cym_m2m.country_id     valuation_country_id, 
       cym_m2m.country_name valuation_country_name, 
       nvl(dgrd.current_qty, 0)  *  (1 - (nvl(vdc.typical, 1) / 100)) * ucm.multiplication_factor qty_in_group_unit, 
       qum_gcd.qty_unit  group_qty_unit, 
       nvl(dgrd.current_qty, 0)  *  (1 - (nvl(vdc.typical, 1) / 100)) qty_in_ctract_unit, 
       qum_dgrd.qty_unit ctract_qty_unit, 
       cm_base_cur.cur_code 
       corp_base_cur, 
       To_char (SYSDATE, 'Mon-yyyy')    delivery_month, 
       cm_invoice_curreny.cur_id        invoice_cur_id, 
       cm_invoice_curreny.cur_code    invoice_cur_code ,
       ucm_base.qum_to_qty_unit base_qty_unit,
       nvl(dgrd.current_qty, 0)  *  (1 - (nvl(vdc.typical, 1) / 100)) * ucm_base.multiplication_factor qty_in_base_unit,
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.country_id ELSE 'NA' END ||' - ' ||
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.city_id ELSE 'NA' END comb_destination_id,
       'NA' comb_origination_id,
       cym_m2m.country_id ||' - ' || cim_m2m.city_id comb_valuation_loc_id
FROM   dgrd_delivered_grd             dgrd,
       gmr_goods_movement_record      gmr,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       v_pci_pcdi_details             pci,
       pdm_productmaster              pdm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       itm_incoterm_master            itm,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       gab_globaladdressbook          gab,
       ak_corporate_user              aku,
       pym_payment_terms_master       pym,
       phd_profileheaderdetails       phd_pcm_cp,
       cm_currency_master             cm_invoice_curreny,
       pcdb_pc_delivery_basis         pcdb,
       cim_citymaster                 cim_pcdb,
       cym_countrymaster              cym_pcdb,
       cim_citymaster                 cim_m2m,
       cym_countrymaster              cym_m2m,
       qum_quantity_unit_master       qum_gcd,
       qum_quantity_unit_master       qum_dgrd,
       cm_currency_master             cm_base_cur,
       ucm_unit_conversion_master     ucm,
       v_conc_shipment_month_year v_ship,
       v_ucm_conversion               ucm_base,
       qat_quality_attributes         qat,
       v_stock_position_assay_id    vsp,
       v_deductible_value_by_ash_id vdc,
       pdcvm_pdc_valuation_month pdcvm
WHERE  dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    dgrd.shed_id = sld.storage_loc_id(+)
AND    sld.city_id = cim_sld.city_id(+)
AND    gmr.discharge_city_id = cim_gmr.city_id(+)
AND    cim_sld.country_id = cym_sld.country_id(+)
AND    cim_gmr.country_id = cym_gmr.country_id(+)
AND    dgrd.internal_contract_item_ref_no =  pci.internal_contract_item_ref_no(+)
AND    dgrd.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdtm.product_type_name = 'Composite'
AND    pdm.base_quantity_unit = qum.qty_unit_id
AND    pci.inco_term_id = itm.incoterm_id(+)
AND    pci.strategy_id = css.strategy_id(+)
AND    pci.profit_center_id = cpc.profit_center_id(+)
AND    cpc.business_line_id = blm.business_line_id(+)
AND    nvl(dgrd.current_qty, 0) > 0
AND    nvl(dgrd.inventory_status, 'NA') <> 'Out'
AND    gmr.corporate_id = akc.corporate_id
AND    akc.groupid = gcd.groupid
AND    dgrd.status = 'Active' 
AND    gmr.created_by = aku.user_id
and    aku.gabid =  gab.gabid(+)
AND    pci.payment_term_id = pym.payment_term_id(+)
AND    pci.cp_id = phd_pcm_cp.profileid(+)
AND    pci.invoice_currency_id = cm_invoice_curreny.cur_id(+)
AND    pcdb.internal_contract_ref_no = pci.internal_contract_ref_no
and    pci.pcdb_id = pcdb.pcdb_id
AND    pcdb.is_active = 'Y'
AND    pcdb.city_id = cim_pcdb.city_id(+)
AND    pcdb.country_id = cym_pcdb.country_id(+)
AND    pci.m2m_city_id = cim_m2m.city_id(+)
AND    pci.m2m_country_id = cym_m2m.country_id(+)
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    ucm.from_qty_unit_id = dgrd.net_weight_unit_id
AND    ucm.to_qty_unit_id = gcd.group_qty_unit_id
AND    cm_base_cur.cur_id = akc.base_cur_id
AND    qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id
AND    pci.pcdi_id = v_ship.pcdi_id(+)
AND    pci.internal_contract_item_ref_no = v_ship.internal_contract_item_ref_no(+)
AND    dgrd.net_weight_unit_id = ucm_base.from_qty_unit_id
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id
AND    qat.quality_id = dgrd.quality_id
AND    dgrd.internal_dgrd_ref_no = vsp.internal_grd_ref_no
AND    vsp.ash_id = vdc.ash_id(+)
and    v_ship.basis_month_year = pdcvm.shipment_month_year(+)
and    v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
--
-- 4.  Stocks
--
UNION ALL
SELECT 'Composite'  Product_Type,
       'Concentrates Shipped But Not TT for Purchase GMRs' section_name,
       gmr.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       grd.product_id product_id,
       pdm.product_desc product_desc,
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
       'Stocks -  Actual Stocks' position_type_id,
       'Stocks' position_type,
       'Actual Stocks' position_sub_type,
       grd.internal_grd_ref_no contract_ref_no,
       'NA' external_reference_no,
       gmr.eff_date issue_date,
       'NA' counter_party_id,
       'NA' counter_party_name,
       'NA' trader_user_id,
       'NA' trader_name,
       'NA' broker_profile_id,
       'NA' broker_name,
       'NA' incoterm_id,
       'NA' incoterm,
       'NA' payment_term_id,
       'NA' payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       'NA' price_type_name,
       'NA' pay_in_cur_id,
       'NA' pay_in_cur_code,
       nvl(v_ship.derivative_def_id, 'NA') derivative_def_id,
       nvl(v_ship.derivative_def_name, 'NA') derivative_def_name,
       nvl(v_ship.exchange_id, 'NA') exchange_id,
       nvl(v_ship.exchange_name, 'NA') exchange_name,
       nvl(v_ship.instrument_id, 'NA') instrument_id,
       nvl(v_ship.instrument_name, 'NA') instrument_name,
       'NA' item_price_string, -- do not need for GMR and Stocks
       cym_gmr_dest_country.country_id dest_country_id,
       cym_gmr_dest_country.country_name dest_country_name,
       cim_gmr_dest_city.city_id dest_city_id,
       cim_gmr_dest_city.city_name dest_city_name,
       to_char(v_ship.basis_month_year, 'Mon-yyyy') period_month_year,
       CASE WHEN pci.delivery_period_type = 'Date' AND pci.is_called_off = 'Y' THEN pci.delivery_from_date
           ELSE to_date('01-' || pci.expected_delivery_month || '-' || pci.expected_delivery_year,'dd-Mon-yyyy')
       END delivery_from_date,
       CASE WHEN pci.delivery_period_type = 'Date' AND pci.is_called_off = 'Y' THEN pci.delivery_from_date
           ELSE to_date('01-' || pci.expected_delivery_month || '-' ||pci.expected_delivery_year,'dd-Mon-yyyy')
       END,
       to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),'Mon-yyyy') valuation_month,  
       (CASE WHEN grd.is_afloat = 'Y' THEN cim_gmr.city_id
           ELSE cim_sld.city_id
       END) valuation_city_id,
       (CASE WHEN grd.is_afloat = 'Y' THEN cim_gmr.city_id
           ELSE cim_sld.city_name
       END) valuation_city_name,
       CASE WHEN grd.is_afloat = 'Y' THEN cym_gmr.country_id
           ELSE cym_sld.country_id
       END valuation_country_id,
       CASE WHEN grd.is_afloat = 'Y' THEN cym_gmr.country_id
           ELSE cym_sld.country_name
       END valuation_country_name,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0)) -
       nvl(grd.title_transfer_out_qty, 0)) *
       (1 - (nvl(vdc.typical, 1) / 100)) * ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0)) - nvl(grd.title_transfer_out_qty, 0)) *
       (1 - (nvl(vdc.typical, 1) / 100)) qty_in_ctract_unit,
       grd.qty_unit_id ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0)) - nvl(grd.title_transfer_out_qty, 0)) *
       (1 - (nvl(vdc.typical, 1) / 100)) * ucm_base.multiplication_factor qty_in_base_unit,
       cym_gmr_dest_country.country_id || ' - ' || cim_gmr_dest_city.city_id comb_destination_id,
       'NA' comb_origination_id,
       CASE WHEN grd.is_afloat = 'Y' THEN cym_gmr.country_id
           ELSE cym_sld.country_id
       END || ' - ' || 
       CASE WHEN grd.is_afloat = 'Y' THEN cim_gmr.city_id
           ELSE cim_sld.city_id
       END comb_valuation_loc_id
FROM   grd_goods_record_detail        grd,
       gmr_goods_movement_record      gmr,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       v_pci_pcdi_details             pci,
       pdm_productmaster              pdm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       qat_quality_attributes         qat,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       cm_currency_master             cm_invoice_currency,
       cim_citymaster                 cim_gmr_dest_city,
       cym_countrymaster              cym_gmr_dest_country,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       cm_currency_master             cm_base_currency,
       pcdi_pc_delivery_item          pcdi,
       v_conc_shipment_month_year v_ship,
       v_ucm_conversion               ucm_base,
       v_stock_position_assay_id    vsp,
       v_deductible_value_by_ash_id vdc,
       pdcvm_pdc_valuation_month pdcvm
WHERE  grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    grd.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdm.base_quantity_unit = qum.qty_unit_id
AND    grd.shed_id = sld.storage_loc_id(+)
AND    sld.city_id = cim_sld.city_id(+)
AND    gmr.discharge_city_id = cim_gmr.city_id(+)
AND    cim_sld.country_id = cym_sld.country_id(+)
AND    cim_gmr.country_id = cym_gmr.country_id(+)
AND    grd.quality_id = qat.quality_id
AND    gmr.corporate_id = akc.corporate_id
AND    akc.groupid = gcd.groupid
AND    grd.is_deleted = 'N'
AND    grd.status = 'Active'
AND    grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
AND    pci.strategy_id = css.strategy_id(+)
AND    pci.profit_center_id = cpc.profit_center_id(+)
AND    cpc.business_line_id = blm.business_line_id(+)
AND    (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) - nvl(grd.title_transfer_out_qty, 0)) > 0
AND    pdtm.product_type_name = 'Composite'
AND    pci.invoice_currency_id = cm_invoice_currency.cur_id(+) 
AND    cym_gmr_dest_country.country_id(+) = gmr.destination_country_id
AND    cim_gmr_dest_city.city_id(+) = gmr.destination_city_id
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    grd.qty_unit_id = ucm.from_qty_unit_id
AND    gcd.group_qty_unit_id = ucm.to_qty_unit_id
AND    cm_base_currency.cur_id = akc.base_cur_id
AND    pci.pcdi_id = pcdi.pcdi_id
AND    pcdi.internal_contract_ref_no = pci.internal_contract_ref_no
AND    pci.pcdi_id = v_ship.pcdi_id(+)
AND    pci.internal_contract_item_ref_no = v_ship.internal_contract_item_ref_no(+)
AND    grd.qty_unit_id = ucm_base.from_qty_unit_id
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id
AND    grd.internal_grd_ref_no = vsp.internal_grd_ref_no
AND    vsp.ash_id = vdc.ash_id(+)
and    nvl(gmr.inventory_status,'NA') ='Out'
and    v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
and    v_ship.basis_month_year = pdcvm.shipment_month_year(+);
/
CREATE OR REPLACE VIEW V_POSITION_MGR AS 
   WITH ucm_mfact AS
        (SELECT ucm.from_qty_unit_id, ucm.to_qty_unit_id,
                qum_from.qty_unit qum_from_qty_unit,
                qum_to.qty_unit qum_to_qty_unit, ucm.multiplication_factor
           FROM ucm_unit_conversion_master ucm,
                qum_quantity_unit_master qum_to,
                qum_quantity_unit_master qum_from
          WHERE ucm.from_qty_unit_id = qum_from.qty_unit_id
            AND ucm.to_qty_unit_id = qum_to.qty_unit_id
            AND ucm.is_active = 'Y'
            AND qum_from.is_deleted = 'N'
            AND qum_to.is_deleted = 'N')
--
-- Derivative Sections Start
--
   SELECT   'NA' AS product_type, 'Derivatives' section_name, t.corporate_id,
            t.corporate_name, NVL (t.business_line_id, 'NA') business_line_id,
            NVL (t.business_line_name, 'NA') business_line_name,
            NVL (t.profit_center_id, 'NA') profit_center_id,
            NVL (t.profit_center_short_name, 'NA') profit_center_short_name,
            NVL (t.profit_center_name, 'NA') profit_center_name,
            NVL (t.strategy_id, 'NA') strategy_id,
            NVL (t.strategy_name, 'NA') strategy_name,
            NVL (t.product_id, 'NA') product_id,
            NVL (t.product_desc, 'NA') product_desc,
            NVL (t.origin_id, 'NA') origin_id,
            NVL (t.origin_name, 'NA') origin_name,
            NVL (t.quality_id, 'NA') quality_id,
            NVL (t.quality_name, 'NA') quality_name,
            t.position_type || ' - ' || t.position_sub_type position_type_id,
            (CASE
                WHEN t.position_type = 'Stocks'
                   THEN 'Inventory'
                WHEN t.position_type = 'Physical'
                   THEN 'Physical Open'
                WHEN t.position_type = 'Flat'
                   THEN 'Flat Open'
                WHEN t.position_type = 'Unpriced'
                   THEN 'Unpriced Open'
                ELSE t.position_type
             END
            ) position_type,
            t.position_sub_type,
            (CASE
                WHEN t.item_no IS NOT NULL AND t.item_no <> 0
                   THEN t.contract_ref_no || ',' || TO_CHAR (t.item_no)
                ELSE t.contract_ref_no
             END
            ) contract_ref_no,
            NVL (t.external_reference_no, 'NA') external_reference_no,
            t.issue_date issue_date,
            NVL (t.counter_party_id, 'NA') counter_party_id,
            NVL (t.counter_party_name, 'NA') counter_party_name,
            NVL (t.trader_user_id, 'NA') trader_user_id,
            NVL (t.trader_name, 'NA') trader_name,
            NVL (t.broker_profile_id, 'NA') broker_profile_id,
            NVL (t.broker_name, 'NA') broker_name,
            NVL (t.incoterm_id, 'NA') incoterm_id,
            NVL (t.incoterm, 'NA') incoterm,
            NVL (t.payment_term_id, 'NA') payment_term_id,
            NVL (t.payment_term, 'NA') payment_term,
            NVL (t.origination_country_id, 'NA') origination_country_id,
            NVL (t.origination_country, 'NA') origination_country,
            NVL (t.origination_city_id, 'NA') origination_city_id,
            NVL (t.origination_city, 'NA') origination_city,
            NVL (t.price_type_name, 'NA') price_type_name,
            NVL (t.pay_in_cur_id, 'NA') pay_in_cur_id,
            NVL (t.pay_in_cur_code, 'NA') pay_in_cur_code,
            NVL (t.derivative_def_id, 'NA') derivative_def_id,
            NVL (t.derivative_def_name, 'NA') derivative_def_name,
            NVL (t.exchange_id, 'NA') exchange_id,
            NVL (t.exchange_name, 'NA') exchange_name,
            NVL (t.instrument_id, 'NA') instrument_id,
            NVL (t.instrument_name, 'NA') instrument_name,
            NVL (t.item_price_string, 'NA') item_price_string,
            NVL (t.destination_country_id, 'NA') dest_country_id,
            NVL (t.cym_dest_country_name, 'NA') dest_country_name,
            NVL (t.destination_city_id, 'NA') dest_city_id,
            NVL (t.cim_dest_city_name, 'NA') dest_city_name,
            CASE
               WHEN t.period_month || '-' || t.period_year =
                                                        '-'
                  THEN TO_CHAR (SYSDATE, 'Mon-YYYY')
               ELSE t.period_month || '-' || t.period_year
            END period_month_year,
            t.delivery_from_date, t.delivery_to_date, t.valuation_month,
            NVL (t.valuation_city_id, 'NA') valuation_city_id,
            NVL (t.valuation_city_name, 'NA') valuation_city_name,
            NVL (t.valuation_country_id, 'NA') valuation_country_id,
            NVL (t.valuation_country_name, 'NA') valuation_country_name,
            NVL (ROUND (SUM (t.qty), 2), 0) qty_in_group_unit,
            NVL (t.group_qty_unit, 'NA') group_qty_unit,
            NVL (ROUND (SUM (t.qty_in_ctract_unit), 2), 0) qty_in_ctract_unit,
            NVL (t.ctract_qty_unit, 'NA') ctract_qty_unit,
            NVL (t.base_cur_code, 'NA') corp_base_cur, t.delivery_month,
            NVL (t.pay_in_cur_id, 'NA') invoice_cur_id,
            NVL (t.pay_in_cur_code, 'NA') invoice_cur_code, base_qty_unit,
            qty_in_base_unit,
               NVL (t.destination_country_id, 'NA')
            || ' - '
            || NVL (t.destination_city_id, 'NA') comb_destination_id,
               NVL (t.origination_country_id, 'NA')
            || ' - '
            || NVL (t.origination_city_id, 'NA') comb_origination_id,
               NVL (t.valuation_country_id, 'NA')
            || ' - '
            || NVL (t.valuation_city_id, 'NA') comb_valuation_loc_id
       FROM (SELECT (CASE
                        WHEN dpm.purpose_name = 'EFP'
                           THEN 'Futures'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Futures'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Futures'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'Futures'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 'Futures'
                        ELSE 'Futures'
                     END
                    ) entity,
                    'Net' mastersectionname,
                    (CASE
                        WHEN dpm.purpose_name IN
                                               ('White Premium', 'Net Hedge')
                           THEN 'Net'
                        ELSE 'Net Pricing'
                     END
                    ) mainsectionname,
                    (CASE
                        WHEN dpm.purpose_name IN ('Speculation', 'Net Hedge')
                           THEN 'Speculation-White Premium'
                        ELSE 'EFP-Hedging'
                     END
                    ) sectionname,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN    'Pricing'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN    'Hedging'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN    'Strategic'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN    'White Premium'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN    'Net Hedge'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        ELSE 'Futures'
                     END
                    ) subsectionname,
                    (CASE
                        WHEN dpm.purpose_name = 'EFP'
                           THEN 2
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 3
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 5
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 4
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 6
                        ELSE 99
                     END
                    ) subsectionorder,
                    dt.corporate_id corporate_id, ak.corporate_name,
                    dt.trade_price_type_id price_type_id,
                    dt.derivative_ref_no contract_ref_no,
                    TO_CHAR
                       (dt.internal_derivative_ref_no
                       ) internal_contract_item_ref_no,
                    dt.trade_type contract_type, dt.trade_date issue_date,
                    dt.leg_no item_no, cpc.profit_center_id profit_center_id,
                    cpc.profit_center_name profit_center_name,
                    cpc.profit_center_short_name profit_center_short_name,
                    pdm.product_id product_id, pdm.product_desc product_desc,
                    css.strategy_id, css.strategy_name,
                    pdm.base_quantity_unit base_quantity_unit,
                    drm.dr_id price_future_contract_id,
                    emt.exchange_id exchange_id,
                    emt.exchange_name exchange_name, drm.instrument_id,
                    dim.instrument_name instrument_name,
                    irm.instrument_type instrument_type,
                    drm.period_date period_date,
                    drm.period_date min_period_date,
                    drm.period_date period_date_diff,
                    drm.period_month period_month,
                    drm.period_year period_year,
                    pdd.derivative_def_id derivative_def_id,
                    pdd.derivative_def_name derivative_def_name,
                    irm.instrument_type_id instrument_type_id,
                    irm.instrument_type instrument_type,
                    dt.quantity_unit_id qty_unit,
                    (CASE
                        WHEN dt.status = 'None'
                           THEN 'Y'
                        ELSE 'N'
                     END
                    ) is_not_verified,
                    dt.is_what_if is_wif_contract,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN 'Pricing Trades'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Hedge Trades'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Strategic Trades'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'White Premium Trades'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 'Net Hedge Trades'
                        ELSE 'Derivative Trades'
                     END
                    ) position_type,
                    (CASE
                        WHEN irm.instrument_type = 'Future'
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Futures'
                        WHEN irm.instrument_type = 'Future'
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Futures'
                        ELSE 'Future'
                     END
                    ) position_sub_type,
                    'NA' origin_id, 'NA' origin_name, 'NA' quality_id,
                    'NA' quality_name, dt.cp_profile_id counter_party_id,
                    phd_cp.companyname counter_party_name,
                    dt.external_ref_no external_reference_no,
                    dt.trader_id trader_user_id,
                    gab.firstname || ' ' || gab.lastname trader_name,
                    phd_broker.profileid broker_profile_id,
                    phd_broker.companyname broker_name, 'NA' incoterm_id,
                    'NA' incoterm, 'NA' payment_term_id, 'NA' payment_term,
                    'NA' price_type_name, 'NA' pay_in_cur_id,
                    'NA' pay_in_cur_code, drm.period_date delivery_from_date,
                    drm.expiry_date delivery_to_date,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) valuation_month,
                    dt.trade_price_unit_id,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END)
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm.multiplication_factor, 0) qty,
                    ucm.qum_to_qty_unit group_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0) qty_in_ctract_unit,
                    qum_act.qty_unit ctract_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm_base.multiplication_factor, 0)
                                                             qty_in_base_unit,
                    ucm_base.qum_to_qty_unit base_qty_unit,
                    blm.business_line_id, blm.business_line_name,
                    'NA' item_price_string, 'NA' origination_country_id,
                    'NA' origination_country, 'NA' origination_city_id,
                    'NA' origination_city, 'NA' location_group_id,
                    'NA' location_group_name, 'NA' loc_group_type_id,
                    'NA' loc_group_type_name, 'NA' destination_city_id,
                    'NA' destination_country_id, 'NA' destination_state_id,
                    'NA' destination_region_id, 'NA' cym_dest_country_name,
                    'NA' cim_dest_city_name, 'NA' sm_dest_state_name,
                    'NA' valuation_city_id, 'NA' valuation_city_name,
                    'NA' valuation_country_id, 'NA' valuation_country_name,
                    'NA' val_loc_group_id, 'NA' val_loc_group_name,
                    'NA' val_loc_group_type_id, 'NA' val_loc_group_type_name,
                    0 contract_price_group_unit,
                    cm_gcd.cur_code group_cur_code,
                    0 contract_price_base_unit,
                    cm_base.cur_code base_cur_code,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) delivery_month
               FROM dt_derivative_trade dt,
                    ak_corporate ak,
                    ak_corporate_user aku,
                    gab_globaladdressbook gab,
                    cpc_corporate_profit_center cpc,
                    drm_derivative_master drm,
                    dim_der_instrument_master dim,
                    irm_instrument_type_master irm,
                    istm_instr_sub_type_master istm,
                    pdd_product_derivative_def pdd,
                    pdm_productmaster pdm,
                    emt_exchangemaster emt,
                    qum_quantity_unit_master qum,
                    qum_quantity_unit_master qum_act,
                    pp_price_point pp,
                    pm_period_master pm,
                    dtm_deal_type_master dtm,
                    css_corporate_strategy_setup css,
                    sdm_strategy_definition_master sdm,
                    gcd_groupcorporatedetails gcd,
                    dpm_derivative_purpose_master dpm,
                    blm_business_line_master blm,
                    phd_profileheaderdetails phd_cp,
                    phd_profileheaderdetails phd_broker,
                    ucm_mfact ucm,
                    ucm_mfact ucm_base,
                    gcd_groupcorporatedetails gcd_group,
                    cm_currency_master cm_gcd,
                    cm_currency_master cm_base,
                    pum_price_unit_master pum_trade
              WHERE dt.corporate_id = ak.corporate_id
                AND dt.trader_id = aku.user_id
                AND aku.gabid = gab.gabid
                AND dt.profit_center_id = cpc.profit_center_id
                AND dt.dr_id = drm.dr_id(+)
                AND drm.instrument_id = dim.instrument_id(+)
                AND dim.instrument_type_id = irm.instrument_type_id(+)
                AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
                AND dim.product_derivative_id = pdd.derivative_def_id(+)
                AND pdd.product_id = pdm.product_id(+)
                AND pdd.exchange_id = emt.exchange_id(+)
                AND pdd.lot_size_unit_id = qum.qty_unit_id(+)
                AND drm.price_point_id = pp.price_point_id(+)
                AND drm.period_type_id = pm.period_type_id(+)
                AND dt.quantity_unit_id = qum_act.qty_unit_id(+)
                AND dt.deal_type_id = dtm.deal_type_id
                AND dt.strategy_id = css.strategy_id
                AND css.strategy_def_id = sdm.strategy_def_id
                AND ak.groupid = gcd.groupid
                AND dt.purpose_id = dpm.purpose_id
                AND cpc.business_line_id = blm.business_line_id(+)
                AND dt.cp_profile_id = phd_cp.profileid(+)
                AND dt.broker_profile_id = phd_broker.profileid(+)
                AND irm.instrument_type = 'Future'
                AND dtm.deal_type_display_name NOT LIKE '%Swap%'
                AND UPPER (dt.status) IN ('NONE', 'VERIFIED')
                AND nvl(DT.TRADED_ON,'Exchange')='Exchange'
                AND NVL (dt.is_internal_trade, 'N') = 'N'
                AND dt.quantity_unit_id = ucm.from_qty_unit_id
                AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
                AND dt.quantity_unit_id = ucm_base.from_qty_unit_id
                AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
                AND ak.groupid = gcd_group.groupid
                AND gcd_group.group_cur_id = cm_gcd.cur_id
                AND ak.base_cur_id = cm_base.cur_id(+)
                AND dt.trade_price_unit_id = pum_trade.price_unit_id(+)
             UNION ALL
             SELECT 'Forward' entity, 'Net' mastersectionname,
                    'Net' mainsectionname, 'Forward' sectionname,
                    'Forward' subsectionname, 5 subsectionorder,
                    dt.corporate_id corporate_id, ak.corporate_name,
                    dt.trade_price_type_id price_type_id,
                    dt.derivative_ref_no contract_ref_no,
                    TO_CHAR
                       (dt.internal_derivative_ref_no
                       ) internal_contract_item_ref_no,
                    dt.trade_type contract_type, dt.trade_date issue_date,
                    dt.leg_no item_no, cpc.profit_center_id profit_center_id,
                    cpc.profit_center_name profit_center_name,
                    cpc.profit_center_short_name profit_center_short_name,
                    pdm.product_id product_id, pdm.product_desc product_desc,
                    css.strategy_id, css.strategy_name,
                    pdm.base_quantity_unit base_quantity_unit,
                    drm.dr_id price_future_contract_id,
                    emt.exchange_id exchange_id,
                    emt.exchange_name exchange_name, drm.instrument_id,
                    dim.instrument_name instrument_name,
                    irm.instrument_type instrument_type,
                    drm.period_date period_date,
                    drm.period_date min_period_date,
                    drm.period_date period_date_diff,
                    drm.period_month period_month,
                    drm.period_year period_year,
                    pdd.derivative_def_id derivative_def_id,
                    pdd.derivative_def_name derivative_def_name,
                    irm.instrument_type_id instrument_type_id,
                    irm.instrument_type instrument_type,
                    dt.quantity_unit_id qty_unit,
                    (CASE
                        WHEN dt.status = 'None'
                           THEN 'Y'
                        ELSE 'N'
                     END
                    ) is_not_verified,
                    dt.is_what_if is_wif_contract,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN 'Pricing Trades'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Hedge Trades'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Strategic Trades'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'White Premium Trades'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 'Net Hedge Trades'
                        ELSE 'Derivative Trades'
                     END
                    ) position_type,
                    (CASE
                        WHEN irm.instrument_type IN('Forward','Future') 
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Forwards'
                        WHEN irm.instrument_type IN ('Forward','Future') 
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Forwards'
                        ELSE 'Forwards'
                     END
                    ) position_sub_type,
                    'NA' origin_id, 'NA' origin_name, 'NA' quality_id,
                    'NA' quality_name, dt.cp_profile_id counter_party_id,
                    phd_cp.companyname counter_party_name,
                    dt.external_ref_no external_reference_no,
                    dt.trader_id trader_user_id,
                    gab.firstname || ' ' || gab.lastname trader_name,
                    phd_broker.profileid broker_profile_id,
                    phd_broker.companyname broker_name, 'NA' incoterm_id,
                    'NA' incoterm, 'NA' payment_term_id, 'NA' payment_term,
                    'NA' price_type_name, 'NA' pay_in_cur_id,
                    'NA' pay_in_cur_code, drm.period_date delivery_from_date,
                    drm.expiry_date delivery_to_date,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) valuation_month,
                    dt.trade_price_unit_id,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END)
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm.multiplication_factor, 0) qty,
                    ucm.qum_to_qty_unit group_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0) qty_in_ctract_unit,
                    qum_act.qty_unit ctract_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm_base.multiplication_factor, 0)
                                                             qty_in_base_unit,
                    ucm_base.qum_to_qty_unit base_qty_unit,
                    blm.business_line_id, blm.business_line_name,
                    'NA' item_price_string, 'NA' origination_country_id,
                    'NA' origination_country, 'NA' origination_city_id,
                    'NA' origination_city, 'NA' location_group_id,
                    'NA' location_group_name, 'NA' loc_group_type_id,
                    'NA' loc_group_type_name, 'NA' destination_city_id,
                    'NA' destination_country_id, 'NA' destination_state_id,
                    'NA' destination_region_id, 'NA' cym_dest_country_name,
                    'NA' cim_dest_city_name, 'NA' sm_dest_state_name,
                    'NA' valuation_city_id, 'NA' valuation_city_name,
                    'NA' valuation_country_id, 'NA' valuation_country_name,
                    'NA' val_loc_group_id, 'NA' val_loc_group_name,
                    'NA' val_loc_group_type_id, 'NA' val_loc_group_type_name,
                    0 contract_price_group_unit,
                    cm_gcd.cur_code group_cur_code,
                    0 contract_price_base_unit,
                    cm_base.cur_code base_cur_code,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) delivery_month
               FROM dt_derivative_trade dt,
                    ak_corporate ak,
                    ak_corporate_user aku,
                    gab_globaladdressbook gab,
                    cpc_corporate_profit_center cpc,
                    drm_derivative_master drm,
                    dim_der_instrument_master dim,
                    irm_instrument_type_master irm,
                    istm_instr_sub_type_master istm,
                    pdd_product_derivative_def pdd,
                    pdm_productmaster pdm,
                    emt_exchangemaster emt,
                    qum_quantity_unit_master qum,
                    qum_quantity_unit_master qum_act,
                    pp_price_point pp,
                    pm_period_master pm,
                    dtm_deal_type_master dtm,
                    css_corporate_strategy_setup css,
                    sdm_strategy_definition_master sdm,
                    gcd_groupcorporatedetails gcd,
                    dpm_derivative_purpose_master dpm,
                    blm_business_line_master blm,
                    phd_profileheaderdetails phd_cp,
                    phd_profileheaderdetails phd_broker,
                    ucm_mfact ucm,
                    ucm_mfact ucm_base,
                    gcd_groupcorporatedetails gcd_group,
                    cm_currency_master cm_gcd,
                    cm_currency_master cm_base,
                    pum_price_unit_master pum_trade
              WHERE dt.corporate_id = ak.corporate_id
                AND dt.trader_id = aku.user_id
                AND aku.gabid = gab.gabid
                AND dt.profit_center_id = cpc.profit_center_id
                AND dt.dr_id = drm.dr_id(+)
                AND drm.instrument_id = dim.instrument_id(+)
                AND dim.instrument_type_id = irm.instrument_type_id(+)
                AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
                AND dim.product_derivative_id = pdd.derivative_def_id(+)
                AND pdd.product_id = pdm.product_id(+)
                AND pdd.exchange_id = emt.exchange_id(+)
                AND pdd.lot_size_unit_id = qum.qty_unit_id(+)
                AND drm.price_point_id = pp.price_point_id(+)
                AND drm.period_type_id = pm.period_type_id(+)
                AND dt.quantity_unit_id = qum_act.qty_unit_id(+)
                AND dt.deal_type_id = dtm.deal_type_id
                AND dt.strategy_id = css.strategy_id
                AND css.strategy_def_id = sdm.strategy_def_id
                AND ak.groupid = gcd.groupid
                AND dt.purpose_id = dpm.purpose_id
                AND cpc.business_line_id = blm.business_line_id(+)
                AND dt.cp_profile_id = phd_cp.profileid(+)
                AND dt.broker_profile_id = phd_broker.profileid(+)
                AND irm.instrument_type in( 'Forward','Future')   
                AND UPPER (dt.status) IN ('NONE', 'VERIFIED')
                AND NVL (dt.is_internal_trade, 'N') = 'N'
                AND nvl(DT.TRADED_ON,'Exchange')='OTC'
                AND dt.quantity_unit_id = ucm.from_qty_unit_id
                AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
                AND dt.quantity_unit_id = ucm_base.from_qty_unit_id
                AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
                AND ak.groupid = gcd_group.groupid
                AND gcd_group.group_cur_id = cm_gcd.cur_id
                AND ak.base_cur_id = cm_base.cur_id(+)
                AND dt.trade_price_unit_id = pum_trade.price_unit_id(+)
             UNION ALL
             SELECT 'Options' entity, 'Net' mastersectionname,
                    'Net' mainsectionname, 'Options' sectionname,
                    'Option Delta' subsectionname, 5 subsectionorder,
                    dt.corporate_id corporate_id, ak.corporate_name,
                    'Fixed' price_type_id,
                    dt.derivative_ref_no contract_ref_no,
                    TO_CHAR
                       (dt.internal_derivative_ref_no
                       ) internal_contract_item_ref_no,
                    dt.trade_type contract_type, dt.trade_date issue_date,
                    dt.leg_no item_no, cpc.profit_center_id profit_center_id,
                    cpc.profit_center_name profit_center_name,
                    cpc.profit_center_short_name profit_center_short_name,
                    pdm.product_id product_id, pdm.product_desc product_desc,
                    css.strategy_id, css.strategy_name,
                    pdm.base_quantity_unit base_quantity_unit,
                    drm.dr_id price_future_contract_id,
                    emt.exchange_id exchange_id,
                    emt.exchange_name exchange_name, drm.instrument_id,
                    dim.instrument_name instrument_name,
                    irm.instrument_type instrument_type,
                    drm.period_date period_date,
                    drm.period_date min_period_date,
                    drm.period_date period_date_diff,
                    drm.period_month period_month,
                    drm.period_year period_year,
                    pdd.derivative_def_id derivative_def_id,
                    pdd.derivative_def_name derivative_def_name,
                    irm.instrument_type_id instrument_type_id,
                    irm.instrument_type instrument_type,
                    dt.quantity_unit_id qty_unit,
                    (CASE
                        WHEN dt.status = 'None'
                           THEN 'Y'
                        ELSE 'N'
                     END
                    ) is_not_verified,
                    dt.is_what_if is_wif_contract,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN 'Pricing Trades'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Hedge Trades'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Strategic Trades'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'White Premium Trades'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 'Net Hedge Trades'
                        ELSE 'Derivative Trades'
                     END
                    ) position_type,
                    (CASE
                        WHEN irm.instrument_type = 'Option Put'
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Puts'
                        WHEN irm.instrument_type = 'Option Put'
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Puts'
                        WHEN irm.instrument_type = 'Option Call'
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Calls'
                        WHEN irm.instrument_type = 'Option Call'
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Calls'
                        ELSE 'Options'
                     END
                    ) position_sub_type,
                    'NA' origin_id, 'NA' origin_name, 'NA' quality_id,
                    'NA' quality_name, dt.cp_profile_id counter_party_id,
                    phd_cp.companyname counter_party_name,
                    dt.external_ref_no external_reference_no,
                    dt.trader_id trader_user_id,
                    gab.firstname || ' ' || gab.lastname trader_name,
                    phd_broker.profileid broker_profile_id,
                    phd_broker.companyname broker_name, 'NA' incoterm_id,
                    'NA' incoterm, 'NA' payment_term_id, 'NA' payment_term,
                    'NA' price_type_name, 'NA' pay_in_cur_id,
                    'NA' pay_in_cur_code, drm.period_date delivery_from_date,
                    drm.expiry_date delivery_to_date,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) valuation_month,
                    dt.strike_price_unit_id,
                      (  (CASE
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Buy'
                                THEN 1
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Sell'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Buy'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Sell'
                                THEN 1
                             ELSE 1
                          END
                         )
                       * NVL (dt.open_quantity, 0)
                       * NVL (vlq.delta, 0)
                      )
                    * NVL (ucm.multiplication_factor, 0) qty,
                    ucm.qum_to_qty_unit group_qty_unit,
                      (  (CASE
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Buy'
                                THEN 1
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Sell'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Buy'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Sell'
                                THEN 1
                             ELSE 1
                          END
                         )
                       * NVL (vlq.delta, 0)
                      )
                    * NVL (dt.open_quantity, 0) qty_in_ctract_unit,
                    qum_act.qty_unit ctract_qty_unit,
                      (  (CASE
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Buy'
                                THEN 1
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Sell'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Buy'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Sell'
                                THEN 1
                             ELSE 1
                          END
                         )
                       * NVL (dt.open_quantity, 0)
                       * NVL (vlq.delta, 0)
                      )
                    * NVL (ucm_base.multiplication_factor, 0)
                                                             qty_in_base_unit,
                    ucm_base.qum_to_qty_unit base_qty_unit,
                    blm.business_line_id, blm.business_line_name,
                    'NA' item_price_string, 'NA' origination_country_id,
                    'NA' origination_country, 'NA' origination_city_id,
                    'NA' origination_city, 'NA' location_group_id,
                    'NA' location_group_name, 'NA' loc_group_type_id,
                    'NA' loc_group_type_name, 'NA' destination_city_id,
                    'NA' destination_country_id, 'NA' destination_state_id,
                    'NA' destination_region_id, 'NA' cym_dest_country_name,
                    'NA' cim_dest_city_name, 'NA' sm_dest_state_name,
                    'NA' valuation_city_id, 'NA' valuation_city_name,
                    'NA' valuation_country_id, 'NA' valuation_country_name,
                    'NA' val_loc_group_id, 'NA' val_loc_group_name,
                    'NA' val_loc_group_type_id, 'NA' val_loc_group_type_name,
                    0 contract_price_group_unit,
                    cm_gcd.cur_code group_cur_code,
                    0 contract_price_base_unit,
                    cm_base.cur_code base_cur_code,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) delivery_month
               FROM dt_derivative_trade dt,
                    ak_corporate ak,
                    ak_corporate_user aku,
                    gab_globaladdressbook gab,
                    cpc_corporate_profit_center cpc,
                    drm_derivative_master drm,
                    dim_der_instrument_master dim,
                    irm_instrument_type_master irm,
                    istm_instr_sub_type_master istm,
                    pdd_product_derivative_def pdd,
                    pdm_productmaster pdm,
                    emt_exchangemaster emt,
                    qum_quantity_unit_master qum,
                    qum_quantity_unit_master qum_act,
                    pp_price_point pp,
                    pm_period_master pm,
                    dtm_deal_type_master dtm,
                    css_corporate_strategy_setup css,
                    sdm_strategy_definition_master sdm,
                    gcd_groupcorporatedetails gcd,
                    dpm_derivative_purpose_master dpm,
                    blm_business_line_master blm,
                    phd_profileheaderdetails phd_cp,
                    phd_profileheaderdetails phd_broker,
                    ucm_mfact ucm,
                    ucm_mfact ucm_base,
                    gcd_groupcorporatedetails gcd_group,
                    cm_currency_master cm_gcd,
                    cm_currency_master cm_base,
                    pum_price_unit_master pum_strike,
                    v_latest_options_quotes vlq
              WHERE dt.corporate_id = ak.corporate_id
                AND dt.trader_id = aku.user_id
                AND aku.gabid = gab.gabid
                AND dt.profit_center_id = cpc.profit_center_id
                AND dt.dr_id = drm.dr_id(+)
                AND drm.instrument_id = dim.instrument_id(+)
                AND dim.instrument_type_id = irm.instrument_type_id(+)
                AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
                AND dim.product_derivative_id = pdd.derivative_def_id(+)
                AND pdd.product_id = pdm.product_id(+)
                AND pdd.exchange_id = emt.exchange_id(+)
                AND pdd.lot_size_unit_id = qum.qty_unit_id(+)
                AND drm.price_point_id = pp.price_point_id(+)
                AND drm.period_type_id = pm.period_type_id(+)
                AND dt.quantity_unit_id = qum_act.qty_unit_id(+)
                AND dt.deal_type_id = dtm.deal_type_id
                AND dt.strategy_id = css.strategy_id
                AND css.strategy_def_id = sdm.strategy_def_id
                AND ak.groupid = gcd.groupid
                AND dt.purpose_id = dpm.purpose_id
                AND cpc.business_line_id = blm.business_line_id(+)
                AND dt.cp_profile_id = phd_cp.profileid(+)
                AND dt.broker_profile_id = phd_broker.profileid(+)
                AND irm.instrument_type IN ('Option Put', 'Option Call')
                AND UPPER (dt.status) IN ('NONE', 'VERIFIED')
                AND NVL (dt.is_internal_trade, 'N') = 'N'
                AND dt.quantity_unit_id = ucm.from_qty_unit_id
                AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
                AND dt.quantity_unit_id = ucm_base.from_qty_unit_id
                AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
                AND ak.groupid = gcd_group.groupid
                AND gcd_group.group_cur_id = cm_gcd.cur_id
                AND ak.base_cur_id = cm_base.cur_id(+)
                AND dt.strike_price_unit_id = pum_strike.price_unit_id(+)
                AND dt.dr_id = vlq.dr_id(+)
                AND dt.corporate_id = vlq.corporate_id(+)
             UNION ALL
             SELECT 'Swaps' entity, 'Net' mastersectionname,
                    'Net' mainsectionname, 'Swaps' sectionname,
                    'Swaps' subsectionname, 5 subsectionorder,
                    dt.corporate_id corporate_id, ak.corporate_name,
                    dt.trade_price_type_id price_type_id,
                    dt.derivative_ref_no contract_ref_no,
                    TO_CHAR
                       (dt.internal_derivative_ref_no
                       ) internal_contract_item_ref_no,
                    dt.trade_type contract_type, dt.trade_date issue_date,
                    dt.leg_no item_no, cpc.profit_center_id profit_center_id,
                    cpc.profit_center_name profit_center_name,
                    cpc.profit_center_short_name profit_center_short_name,
                    pdm.product_id product_id, pdm.product_desc product_desc,
                    css.strategy_id, css.strategy_name,
                    pdm.base_quantity_unit base_quantity_unit,
                    drm.dr_id price_future_contract_id,
                    emt.exchange_id exchange_id,
                    emt.exchange_name exchange_name, drm.instrument_id,
                    dim.instrument_name instrument_name,
                    irm.instrument_type instrument_type,
                    drm.period_date period_date,
                    drm.period_date min_period_date,
                    drm.period_date period_date_diff,
                    drm.period_month period_month,
                    drm.period_year period_year,
                    pdd.derivative_def_id derivative_def_id,
                    pdd.derivative_def_name derivative_def_name,
                    irm.instrument_type_id instrument_type_id,
                    irm.instrument_type instrument_type,
                    dt.quantity_unit_id qty_unit,
                    (CASE
                        WHEN dt.status = 'None'
                           THEN 'Y'
                        ELSE 'N'
                     END
                    ) is_not_verified,
                    dt.is_what_if is_wif_contract,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN 'Pricing Trades'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Hedge Trades'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Strategic Trades'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'White Premium Trades'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 'Net Hedge Trades'
                        ELSE 'Derivative Trades'
                     END
                    ) position_type,
                    (CASE
                        WHEN irm.instrument_type = 'Future'
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Swaps'
                        WHEN irm.instrument_type = 'Future'
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Swaps'
                        ELSE 'Swaps'
                     END
                    ) position_sub_type,
                    'NA' origin_id, 'NA' origin_name, 'NA' quality_id,
                    'NA' quality_name, dt.cp_profile_id counter_party_id,
                    phd_cp.companyname counter_party_name,
                    dt.external_ref_no external_reference_no,
                    dt.trader_id trader_user_id,
                    gab.firstname || ' ' || gab.lastname trader_name,
                    phd_broker.profileid broker_profile_id,
                    phd_broker.companyname broker_name, 'NA' incoterm_id,
                    'NA' incoterm, 'NA' payment_term_id, 'NA' payment_term,
                    'NA' price_type_name, 'NA' pay_in_cur_id,
                    'NA' pay_in_cur_code, drm.period_date delivery_from_date,
                    drm.expiry_date delivery_to_date,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) valuation_month,
                    dt.swap_trade_price_unit_id_1,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END)
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm.multiplication_factor, 0) qty,
                    ucm.qum_to_qty_unit group_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0) qty_in_ctract_unit,
                    qum_act.qty_unit ctract_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm_base.multiplication_factor, 0)
                                                             qty_in_base_unit,
                    ucm_base.qum_to_qty_unit base_qty_unit,
                    blm.business_line_id, blm.business_line_name,
                    'NA' item_price_string, 'NA' origination_country_id,
                    'NA' origination_country, 'NA' origination_city_id,
                    'NA' origination_city, 'NA' location_group_id,
                    'NA' location_group_name, 'NA' loc_group_type_id,
                    'NA' loc_group_type_name, 'NA' destination_city_id,
                    'NA' destination_country_id, 'NA' destination_state_id,
                    'NA' destination_region_id, 'NA' cym_dest_country_name,
                    'NA' cim_dest_city_name, 'NA' sm_dest_state_name,
                    'NA' valuation_city_id, 'NA' valuation_city_name,
                    'NA' valuation_country_id, 'NA' valuation_country_name,
                    'NA' val_loc_group_id, 'NA' val_loc_group_name,
                    'NA' val_loc_group_type_id, 'NA' val_loc_group_type_name,
                    0 contract_price_group_unit,
                    cm_gcd.cur_code group_cur_code,
                    0 contract_price_base_unit,
                    cm_base.cur_code base_cur_code,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) delivery_month
               FROM dt_derivative_trade dt,
                    ak_corporate ak,
                    ak_corporate_user aku,
                    gab_globaladdressbook gab,
                    cpc_corporate_profit_center cpc,
                    drm_derivative_master drm,
                    dim_der_instrument_master dim,
                    irm_instrument_type_master irm,
                    istm_instr_sub_type_master istm,
                    pdd_product_derivative_def pdd,
                    pdm_productmaster pdm,
                    emt_exchangemaster emt,
                    qum_quantity_unit_master qum,
                    qum_quantity_unit_master qum_act,
                    pp_price_point pp,
                    pm_period_master pm,
                    dtm_deal_type_master dtm,
                    css_corporate_strategy_setup css,
                    sdm_strategy_definition_master sdm,
                    gcd_groupcorporatedetails gcd,
                    dpm_derivative_purpose_master dpm,
                    blm_business_line_master blm,
                    phd_profileheaderdetails phd_cp,
                    phd_profileheaderdetails phd_broker,
                    ucm_mfact ucm,
                    ucm_mfact ucm_base,
                    gcd_groupcorporatedetails gcd_group,
                    cm_currency_master cm_gcd,
                    cm_currency_master cm_base,
                    pum_price_unit_master pum_leg
              WHERE dt.corporate_id = ak.corporate_id
                AND dt.trader_id = aku.user_id
                AND aku.gabid = gab.gabid
                AND dt.profit_center_id = cpc.profit_center_id
                AND dt.dr_id = drm.dr_id(+)
                AND drm.instrument_id = dim.instrument_id(+)
                AND dim.instrument_type_id = irm.instrument_type_id(+)
                AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
                AND dim.product_derivative_id = pdd.derivative_def_id(+)
                AND pdd.product_id = pdm.product_id(+)
                AND pdd.exchange_id = emt.exchange_id(+)
                AND pdd.lot_size_unit_id = qum.qty_unit_id(+)
                AND drm.price_point_id = pp.price_point_id(+)
                AND drm.period_type_id = pm.period_type_id(+)
                AND dt.quantity_unit_id = qum_act.qty_unit_id(+)
                AND dt.deal_type_id = dtm.deal_type_id
                AND dt.strategy_id = css.strategy_id
                AND css.strategy_def_id = sdm.strategy_def_id
                AND ak.groupid = gcd.groupid
                AND dt.purpose_id = dpm.purpose_id
                AND cpc.business_line_id = blm.business_line_id(+)
                AND dt.cp_profile_id = phd_cp.profileid(+)
                AND dt.broker_profile_id = phd_broker.profileid(+)
                AND dtm.deal_type_display_name LIKE '%Swap%'
                AND UPPER (dt.status) IN ('NONE', 'VERIFIED')
                AND NVL (dt.is_internal_trade, 'N') = 'N'
                AND dt.quantity_unit_id = ucm.from_qty_unit_id
                AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
                AND dt.quantity_unit_id = ucm_base.from_qty_unit_id
                AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
                AND ak.groupid = gcd_group.groupid
                AND gcd_group.group_cur_id = cm_gcd.cur_id
                AND ak.base_cur_id = cm_base.cur_id(+)
                AND dt.swap_trade_price_unit_id_1 = pum_leg.price_unit_id(+)
             UNION ALL
             SELECT 'Averages' entity, 'Net' mastersectionname,
                    'Net' mainsectionname, 'Averages' sectionname,
                    'Averages' subsectionname, 5 subsectionorder,
                    dt.corporate_id corporate_id, ak.corporate_name,
                    dt.trade_price_type_id price_type_id,
                    dt.derivative_ref_no contract_ref_no,
                    TO_CHAR
                       (dt.internal_derivative_ref_no
                       ) internal_contract_item_ref_no,
                    dt.trade_type contract_type, dt.trade_date issue_date,
                    dt.leg_no item_no, cpc.profit_center_id profit_center_id,
                    cpc.profit_center_name profit_center_name,
                    cpc.profit_center_short_name profit_center_short_name,
                    pdm.product_id product_id, pdm.product_desc product_desc,
                    css.strategy_id, css.strategy_name,
                    pdm.base_quantity_unit base_quantity_unit,
                    drm.dr_id price_future_contract_id,
                    emt.exchange_id exchange_id,
                    emt.exchange_name exchange_name, drm.instrument_id,
                    dim.instrument_name instrument_name,
                    irm.instrument_type instrument_type,
                    drm.period_date period_date,
                    drm.period_date min_period_date,
                    drm.period_date period_date_diff,
                    drm.period_month period_month,
                    drm.period_year period_year,
                    pdd.derivative_def_id derivative_def_id,
                    pdd.derivative_def_name derivative_def_name,
                    irm.instrument_type_id instrument_type_id,
                    irm.instrument_type instrument_type,
                    dt.quantity_unit_id qty_unit,
                    (CASE
                        WHEN dt.status = 'None'
                           THEN 'Y'
                        ELSE 'N'
                     END
                    ) is_not_verified,
                    dt.is_what_if is_wif_contract,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN 'Pricing Trades'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Hedge Trades'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Strategic Trades'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'White Premium Trades'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 'Net Hedge Trades'
                        ELSE 'Derivative Trades'
                     END
                    ) position_type,
                    (CASE
                        WHEN irm.instrument_type = 'Average'
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Forwards'
                        WHEN irm.instrument_type = 'Average'
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Forwards'
                        ELSE 'Forwards'
                     END
                    ) position_sub_type,
                    'NA' origin_id, 'NA' origin_name, 'NA' quality_id,
                    'NA' quality_name, dt.cp_profile_id counter_party_id,
                    phd_cp.companyname counter_party_name,
                    dt.external_ref_no external_reference_no,
                    dt.trader_id trader_user_id,
                    gab.firstname || ' ' || gab.lastname trader_name,
                    phd_broker.profileid broker_profile_id,
                    phd_broker.companyname broker_name, 'NA' incoterm_id,
                    'NA' incoterm, 'NA' payment_term_id, 'NA' payment_term,
                    'NA' price_type_name, 'NA' pay_in_cur_id,
                    'NA' pay_in_cur_code, drm.period_date delivery_from_date,
                    drm.expiry_date delivery_to_date,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) valuation_month,
                    div.price_unit_id,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END)
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm.multiplication_factor, 0) qty,
                    ucm.qum_to_qty_unit group_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0) qty_in_ctract_unit,
                    qum_act.qty_unit ctract_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm_base.multiplication_factor, 0)
                                                             qty_in_base_unit,
                    ucm_base.qum_to_qty_unit base_qty_unit,
                    blm.business_line_id, blm.business_line_name,
                    'NA' item_price_string, 'NA' origination_country_id,
                    'NA' origination_country, 'NA' origination_city_id,
                    'NA' origination_city, 'NA' location_group_id,
                    'NA' location_group_name, 'NA' loc_group_type_id,
                    'NA' loc_group_type_name, 'NA' destination_city_id,
                    'NA' destination_country_id, 'NA' destination_state_id,
                    'NA' destination_region_id, 'NA' cym_dest_country_name,
                    'NA' cim_dest_city_name, 'NA' sm_dest_state_name,
                    'NA' valuation_city_id, 'NA' valuation_city_name,
                    'NA' valuation_country_id, 'NA' valuation_country_name,
                    'NA' val_loc_group_id, 'NA' val_loc_group_name,
                    'NA' val_loc_group_type_id, 'NA' val_loc_group_type_name,
                    0 contract_price_group_unit,
                    cm_gcd.cur_code group_cur_code,
                    0 contract_price_base_unit,
                    cm_base.cur_code base_cur_code,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) delivery_month
               FROM dt_derivative_trade dt,
                    ak_corporate ak,
                    ak_corporate_user aku,
                    gab_globaladdressbook gab,
                    cpc_corporate_profit_center cpc,
                    drm_derivative_master drm,
                    dim_der_instrument_master dim,
                    irm_instrument_type_master irm,
                    istm_instr_sub_type_master istm,
                    pdd_product_derivative_def pdd,
                    pdm_productmaster pdm,
                    emt_exchangemaster emt,
                    qum_quantity_unit_master qum,
                    qum_quantity_unit_master qum_act,
                    pp_price_point pp,
                    pm_period_master pm,
                    dtm_deal_type_master dtm,
                    css_corporate_strategy_setup css,
                    sdm_strategy_definition_master sdm,
                    gcd_groupcorporatedetails gcd,
                    dpm_derivative_purpose_master dpm,
                    blm_business_line_master blm,
                    phd_profileheaderdetails phd_cp,
                    phd_profileheaderdetails phd_broker,
                    ucm_mfact ucm,
                    ucm_mfact ucm_base,
                    gcd_groupcorporatedetails gcd_group,
                    cm_currency_master cm_gcd,
                    cm_currency_master cm_base,
                    div_der_instrument_valuation div,
                    apm_available_price_master apm,
                    pum_price_unit_master pum_avg
              WHERE dt.corporate_id = ak.corporate_id
                AND dt.trader_id = aku.user_id
                AND aku.gabid = gab.gabid
                AND dt.profit_center_id = cpc.profit_center_id
                AND dt.dr_id = drm.dr_id(+)
                AND drm.instrument_id = dim.instrument_id(+)
                AND dim.instrument_type_id = irm.instrument_type_id(+)
                AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
                AND dim.product_derivative_id = pdd.derivative_def_id(+)
                AND pdd.product_id = pdm.product_id(+)
                AND pdd.exchange_id = emt.exchange_id(+)
                AND pdd.lot_size_unit_id = qum.qty_unit_id(+)
                AND drm.price_point_id = pp.price_point_id(+)
                AND drm.period_type_id = pm.period_type_id(+)
                AND dt.quantity_unit_id = qum_act.qty_unit_id(+)
                AND dt.deal_type_id = dtm.deal_type_id
                AND dt.strategy_id = css.strategy_id
                AND css.strategy_def_id = sdm.strategy_def_id
                AND ak.groupid = gcd.groupid
                AND dt.purpose_id = dpm.purpose_id
                AND cpc.business_line_id = blm.business_line_id(+)
                AND dt.cp_profile_id = phd_cp.profileid(+)
                AND dt.broker_profile_id = phd_broker.profileid(+)
                AND irm.instrument_type = 'Average'
                AND UPPER (dt.status) IN ('NONE', 'VERIFIED')
                AND NVL (dt.is_internal_trade, 'N') = 'N'
                AND dt.quantity_unit_id = ucm.from_qty_unit_id
                AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
                AND dt.quantity_unit_id = ucm_base.from_qty_unit_id
                AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
                AND ak.groupid = gcd_group.groupid
                AND gcd_group.group_cur_id = cm_gcd.cur_id
                AND ak.base_cur_id = cm_base.cur_id(+)
                AND dim.underlying_instrument_id = div.instrument_id
                AND div.is_deleted = 'N'
                AND dt.available_price_id = apm.available_price_id
                AND div.price_unit_id = pum_avg.price_unit_id(+)) t,
            v_cdc_drm_month_sequence t_drm
      WHERE t.product_id = t_drm.product_id
        AND t.corporate_id = t_drm.corporate_id
   GROUP BY t.corporate_id,
            t.corporate_name,
            NVL (t.business_line_id, 'NA'),
            NVL (t.business_line_name, 'NA'),
            NVL (t.profit_center_id, 'NA'),
            NVL (t.profit_center_short_name, 'NA'),
            NVL (t.profit_center_name, 'NA'),
            NVL (t.strategy_id, 'NA'),
            NVL (t.strategy_name, 'NA'),
            NVL (t.product_id, 'NA'),
            NVL (t.product_desc, 'NA'),
            NVL (t.origin_id, 'NA'),
            NVL (t.origin_name, 'NA'),
            NVL (t.quality_id, 'NA'),
            NVL (t.quality_name, 'NA'),
            t.position_type || ' - ' || t.position_sub_type,
            (CASE
                WHEN t.position_type = 'Stocks'
                   THEN 'Inventory'
                WHEN t.position_type = 'Physical'
                   THEN 'Physical Open'
                WHEN t.position_type = 'Flat'
                   THEN 'Flat Open'
                WHEN t.position_type = 'Unpriced'
                   THEN 'Unpriced Open'
                ELSE t.position_type
             END
            ),
            t.position_sub_type,
            (CASE
                WHEN t.item_no IS NOT NULL AND t.item_no <> 0
                   THEN t.contract_ref_no || ',' || TO_CHAR (t.item_no)
                ELSE t.contract_ref_no
             END
            ),
            NVL (t.external_reference_no, 'NA'),
            t.issue_date,
            NVL (t.counter_party_id, 'NA'),
            NVL (t.counter_party_name, 'NA'),
            NVL (t.trader_user_id, 'NA'),
            NVL (t.trader_name, 'NA'),
            NVL (t.broker_profile_id, 'NA'),
            NVL (t.broker_name, 'NA'),
            NVL (t.incoterm_id, 'NA'),
            NVL (t.incoterm, 'NA'),
            NVL (t.payment_term_id, 'NA'),
            NVL (t.payment_term, 'NA'),
               NVL (t.origination_country_id, 'NA')
            || ' - '
            || NVL (t.origination_city_id, 'NA'),
            NVL (t.origination_country_id, 'NA'),
            NVL (t.origination_country, 'NA'),
            NVL (t.origination_city_id, 'NA'),
            NVL (t.origination_city, 'NA'),
            NVL (t.price_type_name, 'NA'),
            NVL (t.pay_in_cur_id, 'NA'),
            NVL (t.pay_in_cur_code, 'NA'),
            NVL (t.derivative_def_id, 'NA'),
            NVL (t.derivative_def_name, 'NA'),
            NVL (t.exchange_id, 'NA'),
            NVL (t.exchange_name, 'NA'),
            NVL (t.instrument_id, 'NA'),
            NVL (t.instrument_name, 'NA'),
            NVL (t.item_price_string, 'NA'),
               NVL (t.location_group_id, 'NA')
            || ' - '
            || NVL (t.loc_group_type_id, 'NA'),
            NVL (t.location_group_id, 'NA'),
            NVL (t.location_group_name, 'NA'),
            NVL (t.loc_group_type_id, 'NA'),
            NVL (t.loc_group_type_name, 'NA'),
               NVL (t.destination_country_id, 'NA')
            || ' - '
            || NVL (t.destination_city_id, 'NA'),
            NVL (t.destination_country_id, 'NA'),
            NVL (t.cym_dest_country_name, 'NA'),
            NVL (t.destination_city_id, 'NA'),
            NVL (t.cim_dest_city_name, 'NA'),
            t.period_month || '-' || t.period_year,
            t.delivery_from_date,
            t.delivery_to_date,
            t.valuation_month,
               NVL (t.valuation_country_id, 'NA')
            || ' - '
            || NVL (t.valuation_city_id, 'NA'),
            NVL (t.valuation_city_id, 'NA'),
            NVL (t.valuation_city_name, 'NA'),
            NVL (t.valuation_country_id, 'NA'),
            NVL (t.valuation_country_name, 'NA'),
               NVL (t.val_loc_group_id, 'NA')
            || ' - '
            || NVL (t.val_loc_group_type_id, 'NA'),
            NVL (t.val_loc_group_id, 'NA'),
            NVL (t.val_loc_group_name, 'NA'),
            NVL (t.val_loc_group_type_id, 'NA'),
            NVL (t.val_loc_group_type_name, 'NA'),
            NVL (t.group_qty_unit, 'NA'),
            NVL (t.ctract_qty_unit, 'NA'),
            t.position_type,
            NVL (t.contract_price_base_unit, 0),
            NVL (t.base_cur_code, 'NA'),
            t.delivery_month,
            base_qty_unit,
            qty_in_base_unit
-- 
-- Derivative Sections End
-- 
-- This is for Base Metal Only          
--
UNION ALL 
-- 
-- 1) Open Contracts 
-- 
SELECT 'Standard'  Product_Type,
      'Base Metal Open Contracts' section_name,
       pcm.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       css.strategy_id,
       css.strategy_name,
       pdm.product_id,
       pdm.product_desc,
       nvl(qat.product_origin_id,'NA') origin_id,
       nvl(orm.origin_name,'NA') origin_name,
       qat.quality_id,
       qat.quality_name,
       case when pcm.purchase_sales='P' then 'Physical - Open Purchase'
       else 'Physical - Open Sales'
       end position_type_id,
       'Physical' AS position_type,
       'Open ' || decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') AS position_sub_type,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no contract_ref_no,
       nvl(pcm.cp_contract_ref_no,'NA'),
       pcm.issue_date,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker_name,
       itm.incoterm_id,
       itm.incoterm,
       pym.payment_term_id,
       pym.payment_term,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            pcdb.country_id
           ELSE
            'NA'
       END origination_country_id,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cym_pcdb.country_name
           ELSE
            'NA'
       END origination_country,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cim_pcdb.city_id
           ELSE
            'NA'
       END origination_city_id,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cim_pcdb.city_name
           ELSE
            'NA'
       END origination_city,
       nvl(pcdi.item_price_type,'NA') price_type_name,
       pcm.invoice_currency_id pay_in_cur_id,
       cm_invoice_cur.cur_code pay_in_cur_code,
       nvl(v_ship.derivative_def_id,'NA') derivative_def_id,
       nvl(v_ship.derivative_def_name,'NA') derivative_def_name,
       nvl(v_ship.exchange_id,'NA') exchange_id,
       nvl(v_ship.exchange_name,'NA') exchange_name,
       nvl(v_ship.instrument_id,'NA') instrument_id,
       nvl(v_ship.instrument_name,'NA') instrument_name,
       'NA' item_price_string,
       CASE
           WHEN itm.location_field = 'DESTINATION' THEN
            pcdb.country_id
           ELSE
            'NA'
       END dest_country_id,
       CASE
           WHEN itm.location_field = 'DESTINATION' THEN
            cym_pcdb.country_name
           ELSE
            'NA'
       END dest_country_name,
       CASE
           WHEN itm.location_field = 'DESTINATION' THEN
            cim_pcdb.city_id
           ELSE
            'NA'
       END dest_city_id,
       CASE
           WHEN itm.location_field = 'DESTINATION' THEN
            cim_pcdb.city_name
           ELSE
            'NA'
       END dest_city_name,
       pci.expected_delivery_month ||'-' || pci.expected_delivery_year period_month_year,
       CASE
           WHEN pci.delivery_period_type = 'Date' AND
                pci.is_called_off = 'Y' THEN
            pci.delivery_from_date
           ELSE
            to_date('01-' || pci.expected_delivery_month || '-' ||
                    pci.expected_delivery_year,
                    'dd-Mon-yyyy')
       END,
       CASE
           WHEN pci.delivery_period_type = 'Date' AND
                pci.is_called_off = 'Y' THEN
            pci.delivery_to_date
           ELSE
            to_date('01-' || pci.expected_delivery_month || '-' ||
                    pci.expected_delivery_year,
                    'dd-Mon-yyyy')
       END,
        to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),'Mon-yyyy') valuation_month,
       pci.m2m_city_id valuation_city_id,
       cim_m2m_city.city_name valuation_city_name,
       pci.m2m_country_id valuation_country_id,
       cym_m2m_country.country_name valuation_country_name,
       ciqs.open_qty * ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       ciqs.open_qty qty_in_ctract_unit,
       qum_ciqs.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       pci.expected_delivery_month ||'-' || pci.expected_delivery_year delivery_month,
       pcm.invoice_currency_id invoice_cur_id,
       cm_invoice_cur.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       ciqs.open_qty * ucm_base.multiplication_factor qty_in_base_unit,
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.country_id ELSE 'NA' END || ' - ' ||
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.city_id ELSE 'NA' END comb_destination_id,
       CASE WHEN itm.location_field = 'ORIGINATION' THEN pcdb.country_id ELSE 'NA' END || ' - ' ||
       CASE WHEN itm.location_field = 'ORIGINATION' THEN pcdb.city_id ELSE 'NA' END  comb_origination_id,
       pci.m2m_country_id || ' - ' || pci.m2m_city_id comb_valuation_loc_id
FROM   pci_physical_contract_item     pci,
       pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       ak_corporate                   akc,
       pcpd_pc_product_definition     pcpd,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       css_corporate_strategy_setup   css,
       pdm_productmaster              pdm,
       pcpq_pc_product_quality        pcpq,
       qat_quality_attributes         qat,
       ak_corporate_user              akcu,
       gab_globaladdressbook          gab,
       itm_incoterm_master            itm,
       pcdb_pc_delivery_basis         pcdb,
       pym_payment_terms_master       pym,
       ciqs_contract_item_qty_status  ciqs,
       cm_currency_master             cm_base_cur,
       cm_currency_master             cm_invoice_cur,
       cim_citymaster                 cim_m2m_city,
       cym_countrymaster              cym_m2m_country,
       phd_profileheaderdetails       phd_contract_cp,
       pom_product_origin_master      pom,
       orm_origin_master              orm,
       v_contract_shipment_month_year v_ship,
       cym_countrymaster              cym_pcdb,
       cim_citymaster                 cim_pcdb,
       qum_quantity_unit_master       qum_ciqs,
       gcd_groupcorporatedetails      gcd,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       ucm_mfact ucm_base,
       pdcvm_pdc_valuation_month pdcvm
WHERE  pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdi.pcdi_id = pci.pcdi_id
AND    pci.pcpq_id = pcpq.pcpq_id
AND    pcm.contract_status = 'In Position'
AND    pcm.corporate_id = akc.corporate_id
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    cpc.business_line_id = blm.business_line_id
AND    pcpd.strategy_id = css.strategy_id
AND    pcpd.product_id = pdm.product_id
AND    pcpd.pcpd_id = pcpq.pcpd_id
AND    pcpq.is_active = 'Y'
AND    pci.is_active = 'Y'
AND    pcdi.is_active = 'Y'
AND    ciqs.is_active = 'Y'
AND    pcdb.is_active = 'Y'
AND    pcpq.quality_template_id = qat.quality_id
AND    pcm.trader_id = akcu.user_id
AND    akcu.gabid = gab.gabid
AND    pci.pcdb_id = pcdb.pcdb_id
AND    pcdb.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdb.inco_term_id = itm.incoterm_id
AND    pcm.payment_term_id = pym.payment_term_id
AND    pci.internal_contract_item_ref_no = ciqs.internal_contract_item_ref_no
and    pci.pcpq_id = pcpq.pcpq_id --add
and    pci.pcdb_id = pcdb.pcdb_id --add
AND    cm_base_cur.cur_id = akc.base_cur_id
AND    cm_invoice_cur.cur_id = akc.base_cur_id
AND    cim_m2m_city.city_id = pci.m2m_city_id
AND    cym_m2m_country.country_id = pci.m2m_country_id
AND    phd_contract_cp.profileid = pcm.cp_id
AND    qat.product_origin_id = pom.product_origin_id(+)
AND    pom.origin_id = orm.origin_id(+)
AND    pci.internal_contract_item_ref_no = v_ship.internal_contract_item_ref_no(+)
AND    pci.pcdi_id = v_ship.pcdi_id(+)
AND    ciqs.open_qty > 0
AND    cym_pcdb.country_id = pcdb.country_id
AND    cim_pcdb.city_id = pcdb.city_id
AND    qum_ciqs.qty_unit_id = ciqs.item_qty_unit_id
AND    akc.groupid = gcd.groupid
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    ucm.from_qty_unit_id = ciqs.item_qty_unit_id
AND    ucm.to_qty_unit_id = gcd.group_qty_unit_id
AND    pcm.contract_type = 'BASEMETAL'
AND    pcpq.quality_template_id = qat.quality_id
AND    ciqs.item_qty_unit_id = ucm_base.from_qty_unit_id 
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id
and    v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
and    v_ship.basis_month_year = pdcvm.shipment_month_year(+)
-- 
-- 2) Shipped But Not TT for Purchase GMRs
-- 
UNION ALL 
SELECT 'Standard'  Product_Type,
       'Base Metal Shipped But Not TT for Purchase GMRs' section_name,
       gmr.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       grd.product_id product_id,
       pdm.product_desc product_desc,
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
       'Physical - Open Purchase' position_type_id,
       'Physical' position_type,
       'Open Purchase' position_sub_type,
       CASE
           WHEN pci.contract_ref_no IS NOT NULL THEN
            gmr.gmr_ref_no || ',' || pci.contract_ref_no || ',' ||
            pci.del_distribution_item_no
           ELSE
            gmr.gmr_ref_no
       END contract_ref_no,
       nvl(pci.cp_contract_ref_no, 'NA') external_reference_no,
       gmr.eff_date issue_date,
       pci.cp_id counter_party_id,
       phd_pcm_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_name,
       'NA' broker_profile_id,
       'NA' broker_name,
       pci.incoterm_id incoterm_id,
       itm.incoterm incoterm,
       pci.payment_term_id payment_term_id,
       pym.payment_term payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       nvl(pci.item_price_type, 'NA') price_type_name,
       pci.invoice_currency_id pay_in_cur_id,
       cm_invoice_currency.cur_code pay_in_cur_code,
       nvl(v_ship.derivative_def_id, 'NA') derivative_def_id,
       nvl(v_ship.derivative_def_name, 'NA') derivative_def_name,
       nvl(v_ship.exchange_id, 'NA') exchange_id,
       nvl(v_ship.exchange_name, 'NA') exchange_name,
       nvl(v_ship.instrument_id, 'NA') instrument_id,
       nvl(v_ship.instrument_name, 'NA') instrument_name,
       'NA' item_price_string, -- do not need for GMR and Stocks
       nvl(cym_gmr.country_id,'NA') dest_country_id,
       nvl(cym_gmr.country_name,'NA') dest_country_name,
       nvl(cim_gmr.city_id,'NA') dest_city_id,
       nvl(cim_gmr.city_name,'NA') dest_city_name,
       to_char(v_ship.basis_month_year, 'Mon-yyyy') period_month_year,
       CASE
           WHEN pci.delivery_period_type = 'Date' AND
                pci.is_called_off = 'Y' THEN
            pci.delivery_from_date
           ELSE
            to_date('01-' || pci.expected_delivery_month || '-' ||
                    pci.expected_delivery_year,
                    'dd-Mon-yyyy')
       END delivery_from_date,
       CASE
           WHEN pci.delivery_period_type = 'Date' AND
                pci.is_called_off = 'Y' THEN
            pci.delivery_from_date
           ELSE
            to_date('01-' || pci.expected_delivery_month || '-' ||
                    pci.expected_delivery_year,
                    'dd-Mon-yyyy')
       END,
        to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),'Mon-yyyy') valuation_month,
       nvl((CASE
           WHEN grd.is_afloat = 'Y' THEN
            cim_gmr.city_id
           ELSE
            cim_sld.city_id
       END),'NA') valuation_city_id,
       nvl((CASE
           WHEN grd.is_afloat = 'Y' THEN
            cim_gmr.city_name
           ELSE
            cim_sld.city_name
       END),'NA') valuation_city_name,
       nvl(CASE
           WHEN grd.is_afloat = 'Y' THEN
            cym_gmr.country_id
           ELSE
            cym_sld.country_id
       END,'NA') valuation_country_id,
       nvl(CASE
           WHEN grd.is_afloat = 'Y' THEN
            cym_gmr.country_name
           ELSE
            cym_sld.country_name
       END,'NA') valuation_country_name,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) qty_in_ctract_unit,
       qum_grd.qty_unit ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * ucm_base.multiplication_factor qty_in_base_unit,
       cym_gmr.country_id || ' - ' || cim_gmr.city_id comb_destination_id,
       'NA' comb_origination_id,
       nvl(CASE
           WHEN grd.is_afloat = 'Y' THEN
            cym_gmr.country_id
           ELSE
            cym_sld.country_id
       END || ' - ' || CASE
           WHEN grd.is_afloat = 'Y' THEN
            cim_gmr.city_id
           ELSE
            cim_sld.city_id
       END,'NA') comb_valuation_loc_id
FROM   grd_goods_record_detail        grd,
       gmr_goods_movement_record      gmr,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       v_pci_pcdi_details             pci,
       pdm_productmaster              pdm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       itm_incoterm_master            itm,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       gab_globaladdressbook          gab,
       phd_profileheaderdetails       phd_pcm_cp,
       pym_payment_terms_master       pym,
       cm_currency_master             cm_invoice_currency,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       cm_currency_master             cm_base_currency,
       v_contract_shipment_month_year v_ship,
       ucm_mfact                      ucm_base,
       ak_corporate_user aku,
       qat_quality_attributes qat,
       qum_quantity_unit_master qum_grd,
       pdcvm_pdc_valuation_month pdcvm
WHERE  grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    grd.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdm.base_quantity_unit = qum.qty_unit_id
AND    grd.shed_id = sld.storage_loc_id(+)
AND    sld.city_id = cim_sld.city_id(+)
AND    gmr.discharge_city_id = cim_gmr.city_id(+)
AND    cim_sld.country_id = cym_sld.country_id(+)
AND    cim_gmr.country_id = cym_gmr.country_id(+)
AND    grd.quality_id = qat.quality_id
AND    gmr.corporate_id = akc.corporate_id
AND    akc.groupid = gcd.groupid
AND    grd.is_deleted = 'N'
AND    grd.status = 'Active'
AND    grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
AND    pci.inco_term_id = itm.incoterm_id(+)
AND    pci.strategy_id = css.strategy_id(+)
AND    pci.profit_center_id = cpc.profit_center_id(+)
AND    cpc.business_line_id = blm.business_line_id(+)
AND    (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -   nvl(grd.title_transfer_out_qty, 0)) > 0
and    gmr.created_by = aku.user_id
and    aku.gabid = gab.gabid(+)
AND    pdtm.product_type_name = 'Standard'
AND    phd_pcm_cp.profileid(+) = pci.cp_id
AND    pym.payment_term_id(+) = pci.payment_term_id
AND    gmr.inventory_status = 'In'
AND    cm_invoice_currency.cur_id(+) = pci.invoice_currency_id
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    grd.qty_unit_id = ucm.from_qty_unit_id
AND    gcd.group_qty_unit_id = ucm.to_qty_unit_id
AND    cm_base_currency.cur_id = akc.base_cur_id
AND    pci.pcdi_id = v_ship.pcdi_id(+)
AND    pci.internal_contract_item_ref_no =     v_ship.internal_contract_item_ref_no(+)
AND    grd.qty_unit_id = ucm_base.from_qty_unit_id
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id
and    grd.qty_unit_id = qum_grd.qty_unit_id
and    v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
and    v_ship.basis_month_year = pdcvm.shipment_month_year(+)

UNION ALL 
-- 
-- 3) Shipped But Not TT for Sales GMRs
-- 
SELECT 'Standard'  Product_Type,
       'Base Metal Shipped But Not TT for Sales GMRs' section_name,
       akc.corporate_id                       corporate_id, 
       akc.corporate_name                     corporate_name, 
       blm.business_line_id                   business_line_id, 
       blm.business_line_name                 business_line_name, 
       cpc.profit_center_id                   profit_center_id, 
       cpc.profit_center_short_name           profit_center_short_name, 
       cpc.profit_center_name                 profit_center_name, 
       css.strategy_id                        strategy_id, 
       css.strategy_name                      strategy_name, 
       pdm.product_id                         product_id, 
       pdm.product_desc                       product_desc, 
       'NA'                                   origin_id, 
       'NA'                                   origin_name, 
       qat.quality_id                         quality_id, 
       qat.quality_name                       quality_name, 
       'Physical - Open Sales'               position_type_id, 
       'Physical'                             position_type, 
       'Open Sales'                                position_sub_type, 
       case when pci.contract_ref_no is not null then
       gmr.gmr_ref_no ||',' || pci.contract_ref_no ||',' || pci.del_distribution_item_no               
       else gmr.gmr_ref_no end contract_ref_no, 
       nvl(pci.cp_contract_ref_no,'NA')                 external_reference_no, 
       pci.issue_date                         issue_date, 
       pci.cp_id                              counter_party_id, 
       phd_pcm_cp.companyname                 counter_party_name, 
       gab.gabid                              trader_user_id, 
       gab.firstname || ' ' || gab.lastname   trader_name, 
       'NA' broker_profile_id, 
       'NA' broker_name, 
       itm.incoterm_id 
       incoterm_id, 
       itm.incoterm incoterm, 
       pym.payment_term_id 
       payment_term_id, 
       pym.payment_term 
       payment_term, 
       'NA'        origination_country_id, 
       'NA'        origination_country, 
       'NA'        origination_city_id, 
       'NA'        origination_city, 
       'NA'                             price_type_name, 
       cm_invoice_curreny.cur_id        pay_in_cur_id, 
       cm_invoice_curreny.cur_code      pay_in_cur_code, 
       nvl(v_ship.derivative_def_id,'NA')            derivative_def_id, 
       nvl(v_ship.derivative_def_name,'NA')          derivative_def_name, 
       nvl(v_ship.exchange_id,'NA')                  exchange_id, 
       nvl(v_ship.exchange_name,'NA')                exchange_name, 
       nvl(v_ship.instrument_id,'NA')                instrument_id, 
       nvl(v_ship.instrument_name,'NA')              instrument_name, 
       pcbph.price_description          item_price_string, 
       nvl(CASE 
         WHEN itm.location_field = 'DESTINATION' THEN pcdb.country_id 
         ELSE 'NA' 
       END,'NA') 
       destination_country_id, 
       nvl(CASE 
         WHEN itm.location_field = 'DESTINATION' THEN cym_pcdb.country_name 
         ELSE 'NA' 
       END,'NA') 
       destination_country, 
       nvl(CASE 
         WHEN itm.location_field = 'DESTINATION' THEN cim_pcdb.city_id 
         ELSE 'NA' 
       END,'NA') 
       destination_city_id, 
       nvl(CASE 
         WHEN itm.location_field = 'DESTINATION' THEN cim_pcdb.city_name 
         ELSE 'NA' 
       END,'NA') 
       destination_city, 
       To_char (v_ship.basis_month_year, 'Mon-yyyy')   period_month_year, 
       CASE
           WHEN pci.delivery_period_type = 'Date' AND
                pci.is_called_off = 'Y' THEN
            pci.delivery_from_date
           ELSE
            to_date('01-' || pci.expected_delivery_month || '-' ||
                    pci.expected_delivery_year,
                    'dd-Mon-yyyy')
       END   delivery_from_date, 
       CASE
           WHEN pci.delivery_period_type = 'Date' AND
                pci.is_called_off = 'Y' THEN
            pci.delivery_to_date
           ELSE
            to_date('01-' || pci.expected_delivery_month || '-' ||
                    pci.expected_delivery_year,
                    'dd-Mon-yyyy')
       END   delivery_to_date, 
        to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),'Mon-yyyy') valuation_month,
       cim_m2m.city_id 
       valuation_city_id, 
       cim_m2m.city_name 
       valuation_city_name, 
       cym_m2m.country_id 
       valuation_country_id, 
       cym_m2m.country_name 
       valuation_country_name, 
       dgrd.current_qty * ucm.multiplication_factor  * -1   qty_in_group_unit, 
       qum_gcd.qty_unit 
       group_qty_unit, 
       dgrd.current_qty * -1     qty_in_ctract_unit, 
       qum_dgrd.qty_unit 
       ctract_qty_unit, 
       cm_base_cur.cur_code 
       corp_base_cur, 
       To_char (SYSDATE, 'Mon-yyyy') 
       delivery_month, 
       cm_invoice_curreny.cur_id 
       invoice_cur_id, 
       cm_invoice_curreny.cur_code 
       invoice_cur_code ,
       ucm_base.qum_to_qty_unit base_qty_unit,
       dgrd.current_qty * ucm_base.multiplication_factor * -1 qty_in_base_unit,
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.country_id ELSE 'NA' END ||' - ' ||
       CASE WHEN itm.location_field = 'DESTINATION' THEN pcdb.city_id ELSE 'NA' END comb_destination_id,
       'NA' comb_origination_id,
       cym_m2m.country_id ||' - ' || cim_m2m.city_id comb_valuation_loc_id
FROM   dgrd_delivered_grd dgrd, 
       gmr_goods_movement_record gmr, 
       sld_storage_location_detail sld, 
       cim_citymaster cim_sld, 
       cim_citymaster cim_gmr, 
       cym_countrymaster cym_sld, 
       cym_countrymaster cym_gmr, 
       v_pci_pcdi_details pci, 
       pdm_productmaster pdm, 
       pdtm_product_type_master pdtm, 
       qum_quantity_unit_master qum, 
       itm_incoterm_master itm, 
       qat_quality_attributes qat,
       css_corporate_strategy_setup css, 
       cpc_corporate_profit_center cpc, 
       blm_business_line_master blm, 
       ak_corporate akc, 
       gcd_groupcorporatedetails gcd, 
       gab_globaladdressbook gab, 
       pym_payment_terms_master pym, 
       phd_profileheaderdetails phd_pcm_cp, 
       cm_currency_master cm_invoice_curreny, 
       pcbph_pc_base_price_header pcbph, 
       pcdb_pc_delivery_basis pcdb, 
       cim_citymaster cim_pcdb, 
       cym_countrymaster cym_pcdb, 
       cim_citymaster cim_m2m, 
       cym_countrymaster cym_m2m, 
       qum_quantity_unit_master qum_gcd, 
       qum_quantity_unit_master qum_dgrd, 
       cm_currency_master cm_base_cur, 
       ucm_unit_conversion_master ucm, 
       v_contract_shipment_month_year v_ship,
       ucm_mfact ucm_base,
       ak_corporate_user aku,
       pdcvm_pdc_valuation_month pdcvm
WHERE  dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no 
       AND dgrd.product_id = pdm.product_id 
       AND pdm.product_type_id = pdtm.product_type_id 
       and pdtm.product_type_name='Standard'
       AND pdm.base_quantity_unit = qum.qty_unit_id 
       AND dgrd.shed_id = sld.storage_loc_id(+) 
       AND sld.city_id = cim_sld.city_id(+) 
       AND gmr.discharge_city_id = cim_gmr.city_id(+) 
       AND cim_sld.country_id = cym_sld.country_id(+) 
       AND cim_gmr.country_id = cym_gmr.country_id(+) 
       AND dgrd.quality_id = qat.quality_id 
       AND gmr.corporate_id = akc.corporate_id 
       AND akc.groupid = gcd.groupid 
       AND dgrd.status = 'Active' 
       and pcbph.is_active ='Y'
       and pcdb.is_active ='Y'
       AND dgrd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+) 
       AND pci.inco_term_id = itm.incoterm_id(+) 
       AND pci.strategy_id = css.strategy_id(+) 
       AND pci.profit_center_id = cpc.profit_center_id(+) 
       AND cpc.business_line_id = blm.business_line_id(+) 
       AND Nvl (dgrd.current_qty, 0) > 0 
       AND Nvl (dgrd.inventory_status, 'NA') <> 'Out' 
       AND aku.gabid = gab.gabid(+) 
       and gmr.created_by = aku.user_id
       AND phd_pcm_cp.profileid(+) = pci.cp_id 
       AND pym.payment_term_id(+) = pci.payment_term_id 
       AND pci.invoice_currency_id = cm_invoice_curreny.cur_id(+) 
       AND pcbph.internal_contract_ref_no(+) = pci.internal_contract_ref_no 
       AND pcdb.internal_contract_ref_no = pci.internal_contract_ref_no 
       AND pcdb.country_id = cym_pcdb.country_id(+) 
       AND pcdb.city_id = cim_pcdb.city_id(+) 
       AND cim_m2m.city_id(+) = pci.m2m_city_id 
       AND cym_m2m.country_id(+) = pci.m2m_country_id 
       AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id 
       AND qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id 
       AND cm_base_cur.cur_id = akc.base_cur_id 
       AND ucm.from_qty_unit_id = dgrd.net_weight_unit_id 
       AND ucm.to_qty_unit_id = gcd.group_qty_unit_id 
       AND v_ship.pcdi_id(+) = pci.pcdi_id 
       and pci.internal_contract_item_ref_no = v_ship.internal_contract_item_ref_no(+)
       AND dgrd.net_weight_unit_id = ucm_base.from_qty_unit_id 
       AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id 
       and v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
       and v_ship.basis_month_year = pdcvm.shipment_month_year(+)
UNION ALL 
-- 
-- 
-- 4) Stocks 
-- 
SELECT 'Standard'  Product_Type,
       'Base Metal Stocks' section_name,
       gmr.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       grd.product_id product_id,
       pdm.product_desc product_desc,
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
       'Stocks -  Actual Stocks' position_type_id,
       'Stocks' position_type,
       'Actual Stocks' position_sub_type,
       grd.internal_grd_ref_no contract_ref_no,
       'NA' external_reference_no,
       gmr.inventory_in_date issue_date,
       'NA' counter_party_id,
       'NA' counter_party_name,
       'NA',
       'NA' trader_name,
       'NA' broker_profile_id,
       'NA' broker_name,
       'NA' incoterm_id,
       'NA' incoterm,
       'NA' payment_term_id,
       'NA' payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       'NA' price_type_name,
       'NA' pay_in_cur_id,
       'NA' pay_in_cur_code,
       nvl(v_qat.derivative_def_id,'NA') derivative_def_id,
       nvl(v_qat.derivative_def_name,'NA') derivative_def_name,
       nvl(v_qat.exchange_id,'NA') exchange_id,
       nvl(v_qat.exchange_name,'NA') exchange_name,
       nvl(v_qat.instrument_id,'NA') instrument_id,
       nvl(v_qat.instrument_name,'NA') instrument_name,
       'NA' item_price_string, -- do not need for GMR and Stocks 
       cym_gmr_dest_country.country_id dest_country_id,
       cym_gmr_dest_country.country_name dest_country_name,
       cim_gmr_dest_city.city_id dest_city_id,
       cim_gmr_dest_city.city_name dest_city_name,
       to_char(SYSDATE, 'Mon-yyyy') period_month_year,
       trunc(SYSDATE) delivery_from_date,
       trunc(SYSDATE) delivery_to_date,
       to_char(SYSDATE, 'Mon-yyyy') valuation_month,
       (CASE
           WHEN grd.is_afloat = 'Y' THEN
            cim_gmr.city_id
           ELSE
            cim_sld.city_id
       END) valuation_city_id,
       (CASE
           WHEN grd.is_afloat = 'Y' THEN
            cim_gmr.city_name
           ELSE
            cim_sld.city_name
       END) valuation_city_name,
       CASE
           WHEN grd.is_afloat = 'Y' THEN
            cym_gmr.country_id
           ELSE
            cym_sld.country_id
       END valuation_country_id,
       CASE
           WHEN grd.is_afloat = 'Y' THEN
            cym_gmr.country_name
           ELSE
            cym_sld.country_name
       END valuation_country_name,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) qty_in_ctract_unit,
       grd.qty_unit_id ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       to_char(SYSDATE, 'Mon-yyyy') delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * ucm_base.multiplication_factor,
       cym_gmr_dest_country.country_id || ' - ' || cim_gmr_dest_city.city_id comb_destination_id,
       'NA' comb_origination_id,
       CASE WHEN grd.is_afloat = 'Y' THEN cym_gmr.country_id ELSE cym_sld.country_id END ||' - ' ||
       CASE WHEN grd.is_afloat = 'Y' THEN cim_gmr.country_id ELSE cim_sld.country_id END   comb_valuation_loc_id
FROM   grd_goods_record_detail grd,
       gmr_goods_movement_record gmr,
       sld_storage_location_detail sld,
       cim_citymaster cim_sld,
       cim_citymaster cim_gmr,
       cym_countrymaster cym_sld,
       cym_countrymaster cym_gmr,
       v_pci_pcdi_details pci,
       pdm_productmaster pdm,
       pdtm_product_type_master pdtm,
       qum_quantity_unit_master qum,
       itm_incoterm_master itm,
       v_qat_quality_exch_data v_qat,
       qat_quality_attributes qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center cpc,
       blm_business_line_master blm,
       ak_corporate akc,
       gcd_groupcorporatedetails gcd,
       phd_profileheaderdetails phd_pcm_cp,
       cm_currency_master cm_invoice_currency,
       cim_citymaster cim_gmr_dest_city,
       cym_countrymaster cym_gmr_dest_country,
       qum_quantity_unit_master qum_gcd,
       ucm_unit_conversion_master ucm,
       cm_currency_master cm_base_currency,
       ucm_mfact ucm_base
WHERE  grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    grd.product_id = pdm.product_id
AND    pdm.product_type_id = pdtm.product_type_id
AND    pdtm.product_type_name = 'Standard'
AND    pdm.base_quantity_unit = qum.qty_unit_id
AND    grd.shed_id = sld.storage_loc_id(+)
AND    sld.city_id = cim_sld.city_id(+)
AND    gmr.discharge_city_id = cim_gmr.city_id(+)
AND    cim_sld.country_id = cym_sld.country_id(+)
AND    cim_gmr.country_id = cym_gmr.country_id(+)
AND    grd.quality_id = v_qat.quality_id
and    v_qat.quality_id = qat.quality_id
AND    gmr.corporate_id = akc.corporate_id
AND    akc.groupid = gcd.groupid
AND    grd.is_deleted = 'N'
AND    grd.status = 'Active'
AND    grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
AND    pci.inco_term_id = itm.incoterm_id(+)
AND    pci.strategy_id = css.strategy_id(+)
AND    pci.profit_center_id = cpc.profit_center_id(+)
AND    cpc.business_line_id = blm.business_line_id(+)
AND    (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) - nvl(grd.title_transfer_out_qty, 0)) > 0
AND    phd_pcm_cp.profileid(+) = pci.cp_id
AND    nvl(grd.inventory_status, 'NA') = 'Out'
AND    cm_invoice_currency.cur_id(+) = pci.invoice_currency_id
AND    cym_gmr_dest_country.country_id(+) = gmr.destination_country_id
AND    cim_gmr_dest_city.city_id(+) = gmr.destination_city_id
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    grd.qty_unit_id = ucm.from_qty_unit_id
AND    gcd.group_qty_unit_id = ucm.to_qty_unit_id
AND    cm_base_currency.cur_id = akc.base_cur_id
AND    grd.qty_unit_id = ucm_base.from_qty_unit_id 
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id 
UNION ALL
--
-- 5) Priced Qty
-- 
SELECT 'Standard'  Product_Type,
       'Base Metal Priced Quantity' section_name,
       pcm.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       css.strategy_id,
       css.strategy_name,
       pdm.product_id,
       pdm.product_desc,
       nvl(qat.product_origin_id,'NA') origin_id,
       nvl(orm.origin_name ,'NA') origin_name,
       qat.quality_id,
       qat.quality_name,
       case when pcm.purchase_sales ='P' then 'Flat - Purchase'
       else 'Flat - Sales'
       end  AS position_type_id,
       'Flat' AS position_type,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') AS position_sub_type,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no,
       nvl(pcm.cp_contract_ref_no, 'NA') cp_contract_ref_no,
       pcm.issue_date,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker_name,
       itm.incoterm_id,
       itm.incoterm,
       pym.payment_term_id,
       pym.payment_term,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            pcdb.country_id
           ELSE
            'NA'
       END origination_country_id,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cym_pcdb.country_name
           ELSE
            'NA'
       END origination_country,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cim_pcdb.city_id
           ELSE
            'NA'
       END origination_city_id,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cim_pcdb.city_name
           ELSE
            'NA'
       END origination_city,
       nvl(pcdi.item_price_type, 'NA') price_type_name,
       'NA' pay_in_cur_id,
       'NA' pay_in_cur_code,
       nvl(v_ship.derivative_def_id, 'NA') derivative_def_id,
       nvl(v_ship.derivative_def_name, 'NA') derivative_def_name,
       nvl(v_ship.exchange_id, 'NA') exchange_id,
       nvl(v_ship.exchange_name, 'NA') exchange_name,
       nvl(v_ship.instrument_id, 'NA') instrument_id,
       nvl(v_ship.instrument_name, 'NA') instrument_name,
       nvl(pcbph.price_description, 'NA') item_price_string,
       'NA' dest_country_id,
       'NA' dest_country_name,
       'NA' dest_city_id,
       'NA' dest_city_name,
       pci.expected_delivery_month ||'-' || pci.expected_delivery_year period_month_year,
       case when pci.delivery_period_type ='Date' and pci.is_called_off ='Y' Then
       pci.delivery_from_date
       else
       to_date('01-' ||pci.expected_delivery_month ||'-' || pci.expected_delivery_year,'dd-Mon-yyyy')
       end delivery_from_date,
       case when pci.delivery_period_type ='Date' and pci.is_called_off ='Y' Then
       pci.delivery_to_date
       else
       to_date('01-' ||pci.expected_delivery_month ||'-' || pci.expected_delivery_year,'dd-Mon-yyyy')
       end delivery_from_date,
        to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),'Mon-yyyy') valuation_month,
       'NA' valuation_city_id,
       'NA' valuation_city_name,
       'NA' valuation_country_id,
       'NA' valuation_country_name,
       ((diqs.price_fixed_qty / diqs.total_qty) * ciqs.total_qty) * ucm.multiplication_factor * (decode( pcm.purchase_sales,'P',1,-1)) qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       ((diqs.price_fixed_qty / diqs.total_qty) * ciqs.total_qty)* (decode( pcm.purchase_sales,'P',1,-1)) qty_in_ctract_unit,
       qum_diqs.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       'NA' delivery_month,
       pcm.invoice_currency_id invoice_cur_id,
       cm_invoice_cur.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       ((diqs.price_fixed_qty / diqs.total_qty) * ciqs.total_qty) *   ucm_base.multiplication_factor * (decode( pcm.purchase_sales,'P',1,-1)),
       'NA' comb_destination_id,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            pcdb.country_id
           ELSE
            'NA'
       END || ' - ' || CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            pcdb.city_id
           ELSE
            'NA'
       END comb_origination_id,
       'NA' comb_valuation_loc_id
FROM   pcm_physical_contract_main     pcm,
       pci_physical_contract_item     pci,
       ciqs_contract_item_qty_status  ciqs,
       pcdi_pc_delivery_item          pcdi,
       ak_corporate                   akc,
       pcpd_pc_product_definition     pcpd,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       css_corporate_strategy_setup   css,
       pdm_productmaster              pdm,
       pcpq_pc_product_quality        pcpq,
       qat_quality_attributes         qat,
       ak_corporate_user              akcu,
       gab_globaladdressbook          gab,
       itm_incoterm_master            itm,
       pcdb_pc_delivery_basis         pcdb,
       pym_payment_terms_master       pym,
       diqs_delivery_item_qty_status  diqs,
       cm_currency_master             cm_invoice_cur,
       cm_currency_master             cm_base_cur,
       phd_profileheaderdetails       phd_contract_cp,
       pom_product_origin_master      pom,
       orm_origin_master              orm,
       v_contract_shipment_month_year v_ship,
       cym_countrymaster              cym_pcdb,
       cim_citymaster                 cim_pcdb,
       qum_quantity_unit_master       qum_diqs,
       gcd_groupcorporatedetails      gcd,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       pcbph_pc_base_price_header     pcbph,
       ucm_mfact                      ucm_base,
       poch_price_opt_call_off_header poch,
       pdcvm_pdc_valuation_month pdcvm
WHERE  pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pci.pcdi_id = pcdi.pcdi_id
AND    ciqs.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
AND    pcdi.pcdi_id = diqs.pcdi_id
AND    pcm.contract_status = 'In Position'
AND    pcm.corporate_id = akc.corporate_id
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    cpc.business_line_id = blm.business_line_id
AND    pcpd.strategy_id = css.strategy_id
AND    pcpd.product_id = pdm.product_id
AND    pcpq.pcpd_id = pcpd.pcpd_id
AND    pcpq.quality_template_id = qat.quality_id
AND    pcm.trader_id = akcu.user_id
AND    akcu.gabid = gab.gabid
AND    pcdb.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdb.inco_term_id = itm.incoterm_id
AND    pcm.payment_term_id = pym.payment_term_id
AND    cm_invoice_cur.cur_id = akc.base_cur_id
AND    phd_contract_cp.profileid = pcm.cp_id
AND    qat.product_origin_id = pom.product_origin_id(+)
AND    pom.origin_id = orm.origin_id(+)
AND    v_ship.pcdi_id(+) = pcdi.pcdi_id
AND    cym_pcdb.country_id = pcdb.country_id
AND    cim_pcdb.city_id = pcdb.city_id
AND    qum_diqs.qty_unit_id = diqs.item_qty_unit_id
AND    akc.groupid = gcd.groupid
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    ucm.from_qty_unit_id = diqs.item_qty_unit_id
AND    ucm.to_qty_unit_id = gcd.group_qty_unit_id
AND    pcm.contract_type = 'BASEMETAL'
AND    pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
and    pci.pcpq_id = pcpq.pcpq_id --add
and    pci.pcdb_id = pcdb.pcdb_id --add
AND    pcbph.is_active = 'Y'
AND    cm_base_cur.cur_id = akc.base_cur_id
AND    diqs.item_qty_unit_id = ucm_base.from_qty_unit_id
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id
AND    nvl(diqs.price_fixed_qty, 0) > 0
AND    poch.pcbph_id = pcbph.pcbph_id
AND    poch.pcdi_id = pcdi.pcdi_id
AND    poch.is_active = 'Y'
and    pci.is_active  = 'Y'
and    ciqs.is_active  = 'Y'
and    pcpd.is_active  = 'Y'
and    pcdb.is_active  = 'Y'
and    pcpq.is_active  = 'Y'
and    diqs.is_active ='Y'
and    v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
and    v_ship.basis_month_year = pdcvm.shipment_month_year(+)
and    pcdb.pcdb_id = pci.pcdb_id
and    v_ship.internal_contract_item_ref_no = pci.internal_contract_item_ref_no

union all
--
-- 6) Unpriced Qty
--                         
SELECT 'Standard'  Product_Type,
       'Base Metal Unpriced Quantity' section_name,
       pcm.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       css.strategy_id,
       css.strategy_name,
       pdm.product_id,
       pdm.product_desc,
       nvl(qat.product_origin_id,'NA') origin_id,
       nvl(orm.origin_name ,'NA') origin_name,
       qat.quality_id,
       qat.quality_name,
       case when pcm.purchase_sales='P' then 'Unpriced - Purchase'
       else 'Unpriced - Sales'
       end AS position_type_id,
       'Unpriced' AS position_type,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') AS position_sub_type,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no contract_ref_no,
       nvl(pcm.cp_contract_ref_no,'NA'),
       pcm.issue_date,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker_name,
       itm.incoterm_id,
       itm.incoterm,
       pym.payment_term_id,
       pym.payment_term,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            pcdb.country_id
           ELSE
            'NA'
       END origination_country_id,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cym_pcdb.country_name
           ELSE
            'NA'
       END origination_country,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cim_pcdb.city_id
           ELSE
            'NA'
       END origination_city_id,
       CASE
           WHEN itm.location_field = 'ORIGINATION' THEN
            cim_pcdb.city_name
           ELSE
           'NA'
       END origination_city,
       nvl(pcdi.item_price_type,'NA') price_type_name,
       'NA' pay_in_cur_id,
       'NA' pay_in_cur_code,
       nvl(v_ship.derivative_def_id,'NA') derivative_def_id,
       nvl(v_ship.derivative_def_name,'NA') derivative_def_name,
       nvl(v_ship.exchange_id,'NA') exchange_id,
       nvl(v_ship.exchange_name,'NA') exchange_name,
       nvl(v_ship.instrument_id,'NA') instrument_id,
       nvl(v_ship.instrument_name,'NA') instrument_name,
       pcbph.price_description item_price_string,
       'NA' dest_country_id,
       'NA' dest_country_name,
       'NA' dest_city_id,
       'NA' dest_city_name,
       to_char(v_ship.basis_month_year, 'Mon-yyyy') period_month_year,
       CASE
           WHEN pci.delivery_period_type = 'Date' AND
                pci.is_called_off = 'Y' THEN
            pci.delivery_from_date
           ELSE
            to_date('01-' || pci.expected_delivery_month || '-' ||
                    pci.expected_delivery_year,
                    'dd-Mon-yyyy')
       END,
       CASE
           WHEN pci.delivery_period_type = 'Date' AND
                pci.is_called_off = 'Y' THEN
            pci.delivery_to_date
           ELSE
            to_date('01-' || pci.expected_delivery_month || '-' ||
                    pci.expected_delivery_year,
                    'dd-Mon-yyyy')
       END,
        to_char((case
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'NA' then
                  v_ship.basis_month_year
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Closest' then
                  nvl(pdcvm.val_month_year_closest, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Previous' then
                  nvl(pdcvm.val_month_year_previous, v_ship.basis_month_year)
                 when nvl(v_ship.exch_valuation_month, 'NA') = 'Next' then
                  nvl(pdcvm.val_month_year_next, v_ship.basis_month_year)
                 else
                  v_ship.basis_month_year
               end),'Mon-yyyy') valuation_month,
       'NA' valuation_city_id,
       'NA' valuation_city_name,
       'NA' valuation_country_id,
       'NA' valuation_country_name,
       round((((diqs.total_qty - diqs.price_fixed_qty)/ diqs.total_qty)*ciqs.total_qty),10) * ucm.multiplication_factor * (decode( pcm.purchase_sales,'P',1,-1)) qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       round((((diqs.total_qty - diqs.price_fixed_qty)/ diqs.total_qty)*ciqs.total_qty),10) * (decode( pcm.purchase_sales,'P',1,-1)) qty_in_ctract_unit,
       qum_pocd.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pcm.invoice_currency_id invoice_cur_id,
       cm_invoice_cur.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       round((((diqs.total_qty - diqs.price_fixed_qty)/ diqs.total_qty)*ciqs.total_qty),10) * ucm_base.multiplication_factor * (decode( pcm.purchase_sales,'P',1,-1)),
       'NA' comb_destination_id,
       CASE WHEN itm.location_field = 'ORIGINATION' THEN pcdb.country_id ELSE 'NA' END ||' - ' ||
       CASE WHEN itm.location_field = 'ORIGINATION' THEN pcdb.city_id ELSE 'NA' END comb_origination_id,
       'NA' comb_valuation_loc_id
FROM   pci_physical_contract_item     pci,
       pcm_physical_contract_main     pcm,
       ciqs_contract_item_qty_status  ciqs,
       pcdi_pc_delivery_item          pcdi,
       ak_corporate                   akc,
       pcpd_pc_product_definition     pcpd,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       css_corporate_strategy_setup   css,
       pdm_productmaster              pdm,
       pcpq_pc_product_quality        pcpq,
       qat_quality_attributes         qat,
       ak_corporate_user              akcu,
       gab_globaladdressbook          gab,
       itm_incoterm_master            itm,
       pcdb_pc_delivery_basis         pcdb,
       pym_payment_terms_master       pym,
       cm_currency_master             cm_invoice_cur,
       phd_profileheaderdetails       phd_contract_cp,
       pom_product_origin_master      pom,
       orm_origin_master              orm,
       v_contract_shipment_month_year v_ship,
       cym_countrymaster              cym_pcdb,
       pcbph_pc_base_price_header     pcbph,
       pcipf_pci_pricing_formula      pcipf,
       cim_citymaster                 cim_pcdb,
       qum_quantity_unit_master       qum_pocd,
       gcd_groupcorporatedetails      gcd,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       cm_currency_master             cm_base_cur,
       ucm_mfact                      ucm_base,
       diqs_delivery_item_qty_status  diqs,
       pdcvm_pdc_valuation_month pdcvm
WHERE  pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    ciqs.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
AND    pcdi.pcdi_id = pci.pcdi_id
AND    diqs.pcdi_id = pci.pcdi_id
AND    pcm.contract_status = 'In Position'
AND    pcm.corporate_id = akc.corporate_id
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    cpc.business_line_id = blm.business_line_id
AND    pci.pcpq_id = pcpq.pcpq_id -- correct join
AND    pci.pcdb_id = pcdb.pcdb_id -- correct join
AND    pcpd.strategy_id = css.strategy_id
AND    pcpd.product_id = pdm.product_id
AND    pcpq.pcpd_id = pcpd.pcpd_id
AND    pcpq.quality_template_id = qat.quality_id
AND    pcm.trader_id = akcu.user_id
AND    akcu.gabid = gab.gabid
AND    pcdb.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdb.inco_term_id = itm.incoterm_id
AND    pcm.payment_term_id = pym.payment_term_id
AND    cm_invoice_cur.cur_id = akc.base_cur_id
AND    phd_contract_cp.profileid = pcm.cp_id
AND    qat.product_origin_id = pom.product_origin_id(+)
AND    pom.origin_id = orm.origin_id(+)
AND    v_ship.pcdi_id(+) = pcdi.pcdi_id
and    v_ship.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
AND    cym_pcdb.country_id(+) = pcdb.country_id
AND    cim_pcdb.city_id(+) = pcdb.city_id
AND    akc.groupid = gcd.groupid
AND    qum_gcd.qty_unit_id = gcd.group_qty_unit_id
AND    pcbph.internal_contract_ref_no(+) = pcm.internal_contract_ref_no
and    pcbph.pcbph_id = pcipf.pcbph_id
AND    ucm.from_qty_unit_id = diqs.item_qty_unit_id
AND    ucm.to_qty_unit_id = gcd.group_qty_unit_id
AND    qum_pocd.qty_unit_id = diqs.item_qty_unit_id
AND    pcm.contract_type = 'BASEMETAL'
AND    cm_base_cur.cur_id = akc.base_cur_id
AND    diqs.item_qty_unit_id = ucm_base.from_qty_unit_id
AND    pdm.base_quantity_unit = ucm_base.to_qty_unit_id
AND    diqs.total_qty - diqs.price_fixed_qty > 0
and    pci.internal_contract_item_ref_no = pcipf.internal_contract_item_ref_no
and    pci.pcpq_id = pcpq.pcpq_id --add
and    pci.pcdb_id = pcdb.pcdb_id --add
and    pci.is_active ='Y'
and    ciqs.is_active ='Y'
and    pcdi.is_active ='Y'
and    pcpd.is_active ='Y'
and    pcdb.is_active ='Y'
and    pcpq.is_active ='Y'
and    pcipf.is_active ='Y'
and    diqs.is_active ='Y'
and    v_ship.delivery_calender_id = pdcvm.prompt_delivery_calendar_id(+)
and    v_ship.basis_month_year = pdcvm.shipment_month_year(+)
UNION ALL
SELECT product_type,
       section_name,
       corporate_id,
       corporate_name,
       business_line_id,
       business_line_name,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       strategy_id,
       strategy_name,
       product_id,
       product_desc,
       origin_id,
       origin_name,
       quality_id,
       quality_name,
       position_type_id,
       position_type,
       position_sub_type,
       contract_ref_no,
       cp_contract_ref_no,
       issue_date,
       counter_party_id,
       counter_party_name,
       trader_user_id,
       trader_user_name,
       broker_profile_id,
       broker_name,
       incoterm_id,
       incoterm,
       payment_term_id,
       payment_term,
       origination_country_id,
       origination_country,
       origination_city_id,
       origination_city,
       price_type_name,
       pay_in_cur_id,
       pay_in_cur_code,
       derivative_def_id,
       derivative_def_name,
       exchange_id,
       exchange_name,
       instrument_id,
       instrument_name,
       item_price_string,
       dest_country_id,
       dest_country_name,
       dest_city_id,
       dest_city_name,
       period_month_year,
       delivery_from_date,
       delivery_to_date,
       valuation_month,
       valuation_city_id,
       valuation_city_name,
       valuation_country_id,
       valuation_country_name,
       qty_in_group_unit,
       group_qty_unit,
       qty_in_ctract_unit,
       ctract_qty_unit,
       corp_base_cur,
       delivery_month,
       invoice_cur_id,
       invoice_cur_code,
       base_qty_unit,
       qty_in_base_unit,
       comb_destination_id,
       comb_origination_id,
       comb_valuation_loc_id
FROM   v_conc_position;
/
DROP MATERIALIZED VIEW MV_FACT_PHY_UNREAL_FIXED_PRICE;
DROP TABLE MV_FACT_PHY_UNREAL_FIXED_PRICE;
CREATE MATERIALIZED VIEW MV_FACT_PHY_UNREAL_FIXED_PRICE 
AS 
SELECT poud.corporate_id, poud.corporate_name,
       pdm.product_type_id product_type, poud.profit_center_id,
       poud.profit_center_short_name profit_center, poud.strategy_id,
       poud.strategy_name, poud.product_id product_id,
       poud.product_name product_name, poud.quality_id quality_id,
       poud.quality_name quality_name, poud.eod_trade_date eod_date,
       'Physical' position_type,
       (CASE
           WHEN poud.contract_type = 'P'
              THEN 'Open Purchase'
           ELSE 'Open Sales'
        END
       ) position_sub_type,
          poud.contract_ref_no
       || '('
       || poud.delivery_item_no
       || ')' contract_ref_no,
       'NA' external_ref_no, poud.contract_issue_date issue_trade_date,
       poud.cp_profile_id cp_id, poud.cp_name cp_name, poud.incoterm,
       poud.payment_term, poud.group_cur_code group_currency,
       poud.base_cur_code corp_currency,
         (CASE
             WHEN poud.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * poud.item_qty contract_quantity,
       poud.qty_unit contract_quantity_uom,
         (CASE
             WHEN poud.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * poud.qty_in_base_unit quantity_in_base_uom,
       0 quantity_in_lots, poud.contract_price,
          poud.price_unit_cur_code
       || '/'
       || DECODE (poud.price_unit_weight,
                  1, NULL,
                  0, NULL,
                  poud.price_unit_weight
                 )
       || poud.price_unit_weight_unit contract_price_unit,
       poud.contract_value_in_price_cur net_contract_value, --in base currency
       poud.contract_premium_value net_contract_premium_value,
       poud.sc_in_base_cur net_sc_cost, 0 contract_treatment_charge,
       0 contract_refining_charge, 0 contract_penalty_charge,
       md.instrument_id valuation_instrument_id,      --valuation_instument_id
       dim.instrument_name valuation_instrument,
       md.derivative_def_id derivative_def_id,
       md.derivative_def_name derivative_def_name,
       md.valuation_month valuation_month, md.valuation_date value_date,
       poud.expected_cog_in_val_cur total_cost_in_m2m_currency,
       poud.m2m_amt_cur_code m2m_currency,
       poud.expected_cog_net_sale_value expected_cog_net_sale_value,
       --m2m valuation details
       (CASE
           WHEN md.valuation_method = 'DIFFERENTIAL'
              THEN md.m2m_settlement_price
           ELSE 0
        END
       ) m2m_settlement_price,
          poud.m2m_price_cur_code
       || '/'
       || DECODE (poud.m2m_price_weight,
                  1, NULL,
                  0, NULL,
                  poud.m2m_price_weight
                 )
       || poud.m2m_price_weight_unit settlement_price_unit,
       md.valuation_city_id, md.valuation_location valuation_city,
       cim.country_id valuation_country_id,
       md.valuation_location_country valuation_country, md.m2m_diff m2m_basis,
       (  NVL (md.m2m_loc_incoterm_deviation, 0)
        + NVL (md.m2m_location_deviation, 0)
        + NVL (md.m2m_incoterm_deviation, 0)
       ) m2m_loc_incoterm_deviation,
       NVL (md.m2m_quality_premium, 0) m2m_quality_premium,
       NVL (md.m2m_product_premium, 0) m2m_product_premium,
       0 m2m_treatment_charge, 0 m2m_refining_charge, 0 m2m_penality_charge,
       poud.net_m2m_price net_settlement_price,
       poud.m2m_amt market_value_in_val_ccy,
       poud.m2m_amt_cur_id market_value_cur_id,
       poud.m2m_amt_cur_code market_value_cur_code,
       NVL (poud.prev_day_unr_pnl_in_base_cur,
            0) prev_day_unr_pnl_in_base_cur,
       NVL (poud.unrealized_pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       NVL (poud.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       poud.base_cur_id base_cur_id, poud.base_cur_code base_cur_code,
       poud.base_qty_unit base_quantity_uom
  FROM poud_phy_open_unreal_daily@eka_eoddb poud,
       md_m2m_daily@eka_eoddb md,
       dim_der_instrument_master@eka_eoddb dim,
       tdc_trade_date_closure@eka_eoddb tdc,
       cim_citymaster@eka_eoddb cim,
       qat_quality_attributes@eka_eoddb qat,
       pdm_productmaster@eka_eoddb pdm
 WHERE poud.process_id = tdc.process_id
   AND poud.md_id = md.md_id
   AND poud.process_id = md.process_id
   AND md.instrument_id = dim.instrument_id(+)
   AND md.valuation_city_id = cim.city_id
   AND poud.quality_id = qat.quality_id
   AND poud.product_id = pdm.product_id
   AND tdc.process = 'EOD'
   and poud.price_type_id <> 'Fixed'
UNION ALL
SELECT pss.corporate_id, akc.corporate_name, pdm.product_type_id product_type,
       pss.profit_center_id, cpc.profit_center_short_name profit_center,
       pss.strategy_id, pss.strategy_name, pss.product_id product_id,
       pss.product_name product_name, pss.quality_id quality_id,
       pss.quality_name quality_name, tdc.trade_date eod_date,
       'Physical' position_type,
       (CASE
           WHEN pss.section_name IN ('Shipped NTT', 'Stock NTT')
              THEN (CASE
                       WHEN pss.contract_type = 'P'
                          THEN 'Shipped but title not transferred on Purchase'
                       ELSE 'Shipped but title not transferred on Sales'
                    END
                   )
           WHEN pss.section_name IN
                         ('Shipped TT', 'Stock TT', 'Shipped IN', 'Stock IN')
              THEN (CASE
                       WHEN pss.contract_type = 'P'
                          THEN 'Inventory Purchase'
                       ELSE 'Inventory Sales'
                    END
                   )
        END
       ) position_sub_type,
       pss.gmr_ref_no || '- ' || pss.stock_ref_no contract_ref_no,
       'NA' external_ref_no, NULL issue_date, 'NA' cp_id, 'NA' cp_name,
       'NA' incoterm, 'NA' payment_term, cm.cur_code group_currency,
       pss.base_cur_code corp_currency,
         (CASE
             WHEN pss.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * pss.stock_qty contract_quantity,
       pss.qty_unit contract_quantity_uom,
         (CASE
             WHEN pss.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * pss.qty_in_base_unit quantity_in_base_uom,
       0 quantity_in_lots, pss.contract_price,
          pss.price_unit_cur_code
       || '/'
       || DECODE (pss.price_unit_weight,
                  1, NULL,
                  0, NULL,
                  pss.price_unit_weight
                 )
       || pss.price_unit_weight_unit contract_price_unit,
       pss.contract_value_in_price_cur net_contract_value,  --in base currency
       pss.contract_premium_value net_contract_premium_value,
       NVL (pss.sc_in_base_cur, 0) net_sc_cost, 0 contract_treatment_charge,
       0 contract_refining_charge, 0 contract_penalty_charge,
       md.instrument_id valuation_instrument_id,      --valuation_instument_id
       dim.instrument_name valuation_instrument,
       md.derivative_def_id derivative_def_id,
       md.derivative_def_name derivative_def_name,
       md.valuation_month valuation_month, md.valuation_date value_date,
       pss.expected_cog_in_val_cur total_cost_in_m2m_currency,
       pss.m2m_amt_cur_code m2m_currency,
       pss.expected_cog_in_base_cur expected_cog_net_sale_value,
       
       --m2m valuation details
       (CASE
           WHEN md.valuation_method = 'DIFFERENTIAL'
              THEN md.m2m_settlement_price
           ELSE 0
        END
       ) m2m_settlement_price,
       pss.m2m_price_unit_str settlement_price_unit, md.valuation_city_id,
       md.valuation_location valuation_city,
       cim.country_id valuation_country_id,
       md.valuation_location_country valuation_country, md.m2m_diff m2m_basis,
       (  NVL (md.m2m_loc_incoterm_deviation, 0)
        + NVL (md.m2m_location_deviation, 0)
        + NVL (md.m2m_incoterm_deviation, 0)
       ) m2m_loc_incoterm_deviation,
       NVL (md.m2m_quality_premium, 0) m2m_quality_premium,
       NVL (md.m2m_product_premium, 0) m2m_product_premium,
       0 m2m_treatment_charge, 0 m2m_refining_charge, 0 m2m_penality_charge,
       pss.net_m2m_price net_settlement_price,
       
       --unrealized pnl
       pss.m2m_amt market_value_in_val_ccy,
       pss.m2m_amt_cur_id market_value_cur_id,
       pss.m2m_amt_cur_code market_value_cur_code,
       NVL (pss.prev_day_pnl_in_base_cur, 0) prev_day_unr_pnl_in_base_cur,
       NVL (pss.pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       NVL (pss.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       pss.base_cur_id base_cur_id, pss.base_cur_code base_cur_code,
       pss.prod_base_unit base_quantity_uom
  FROM psu_phy_stock_unrealized@eka_eoddb pss,
       ak_corporate@eka_eoddb akc,
       gcd_groupcorporatedetails@eka_eoddb gcd,
       cpc_corporate_profit_center@eka_eoddb cpc,
       cm_currency_master@eka_eoddb cm,
       md_m2m_daily@eka_eoddb md,
       cim_citymaster@eka_eoddb cim,
       dim_der_instrument_master@eka_eoddb dim,
       tdc_trade_date_closure@eka_eoddb tdc,
       pdm_productmaster@eka_eoddb pdm
 WHERE pss.process_id = tdc.process_id
   AND pss.corporate_id = tdc.corporate_id
   AND pss.md_id = md.md_id
   AND pss.process_id = md.process_id
   AND pss.profit_center_id = cpc.profit_center_id
   AND md.instrument_id = dim.instrument_id(+)
   AND pss.corporate_id = akc.corporate_id
   AND akc.groupid = gcd.groupid
   AND gcd.group_cur_id = cm.cur_id(+)
   AND md.valuation_city_id = cim.city_id
   AND pss.product_id = pdm.product_id
   AND tdc.process = 'EOD'
   and pss.price_type_id <> 'Fixed'
UNION ALL
SELECT poud.corporate_id, poud.corporate_name,
       pdm.product_type_id product_type, poud.profit_center_id,
       poud.profit_center_short_name profit_center, poud.strategy_id,
       poud.strategy_name, poud.product_id product_id,
       poud.product_name product_name, poud.quality_id quality_id,
       poud.quality_name quality_name, poud.process_trade_date eod_date,
       'Physical' position_type,
       (CASE
           WHEN poud.contract_type = 'P'
              THEN 'Open Purchase'
           ELSE 'Open Sales'
        END
       ) position_sub_type,
          poud.contract_ref_no
       || '('
       || poud.delivery_item_no
       || ')' contract_ref_no,
       'NA' external_ref_no, poud.contract_issue_date issue_trade_date,
       poud.cp_profile_id cp_id, poud.cp_name cp_name, poud.incoterm,
       poud.payment_term, poud.group_cur_code group_currency,
       poud.base_cur_code corp_currency,
         (CASE
             WHEN poud.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * poud.item_dry_qty contract_quantity,
       poud.qty_unit contract_quantity_uom,
         (CASE
             WHEN poud.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * NVL (poud.item_dry_qty, 0)
       * NVL (ucm.multiplication_factor, 0) quantity_in_base_uom,
       0 quantity_in_lots, 0 contract_price,
       poud.contract_price_string contract_price_unit,
       poud.net_contract_prem_in_base_cur net_contract_value,
                                                            --in base currency
       0 net_contract_premium_value, poud.net_sc_in_base_cur net_sc_cost,
       NVL (poud.net_contract_treatment_charge, 0) contract_treatment_charge,
       NVL (poud.net_contract_refining_charge, 0) contract_refining_charge,
       NVL (poud.penalty_charge, 0) contract_penalty_charge,
       'NA' valuation_instrument_id,                  --valuation_instument_id
                                    'NA' valuation_instrument,
       'NA' derivative_def_id, 'NA' derivative_def_name, 'NA' valuation_month,
       NULL value_date,
       poud.expected_cog_net_sale_value total_cost_in_m2m_currency,
       poud.base_cur_code m2m_currency,                        --base currency
       poud.expected_cog_net_sale_value expected_cog_net_sale_value,
       
       --m2m valuation details
       0 m2m_settlement_price, poud.m2m_price_string settlement_price_unit,
       'NA' valuation_city_id, 'NA' valuation_city, 'NA' valuation_country_id,
       'NA' valuation_country, 0 m2m_basis,
       NVL (m2m_loc_diff_premium, 0) m2m_loc_incoterm_deviation,
       0 m2m_quality_premium, 0 m2m_product_premium,
       NVL (poud.net_m2m_treatment_charge, 0) m2m_treatment_charge,
       NVL (poud.net_m2m_refining_charge, 0) m2m_refining_charge,
       NVL (poud.m2m_penalty_charge, 0) m2m_penality_charge,
       0 net_settlement_price,
       
       --unrealized pnl
       poud.net_m2m_amt_in_base_cur market_value_in_val_ccy,
       poud.base_cur_id market_value_cur_id,
       poud.base_cur_code market_value_cur_code,
       NVL (poud.prev_day_unr_pnl_in_base_cur,
            0) prev_day_unr_pnl_in_base_cur,
       NVL (poud.unrealized_pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       NVL (poud.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       poud.base_cur_id base_cur_id, poud.base_cur_code base_cur_code,
       poud.base_qty_unit base_quantity_uom
  FROM poue_phy_open_unreal_element@eka_eoddb poud,
       tdc_trade_date_closure@eka_eoddb tdc,
       ucm_unit_conversion_master@eka_eoddb ucm,
       pdm_productmaster@eka_eoddb pdm
 WHERE poud.process_id = tdc.process_id
   AND poud.corporate_id = tdc.corporate_id
   AND ucm.from_qty_unit_id = poud.qty_unit_id
   AND ucm.to_qty_unit_id = poud.base_qty_unit_id
   AND poud.product_id = pdm.product_id
   AND ucm.is_active = 'Y'
   AND tdc.process = 'EOD'
UNION ALL
SELECT pss.corporate_id, akc.corporate_name, pdm.product_type_id product_type,
       pss.profit_center_id, cpc.profit_center_short_name profit_center,
       pss.strategy_id, pss.strategy_name, pss.product_id conc_product_id,
       pss.product_name conc_product_name, pss.quality_id conc_quality_id,
       pss.quality_name conc_quality_name, tdc.trade_date eod_date,
       'Physical' position_type,
       (CASE
           WHEN pss.section_name IN ('Shipped NTT', 'Stock NTT')
              THEN (CASE
                       WHEN pss.contract_type = 'P'
                          THEN 'Shipped but title not transferred on Purchase'
                       ELSE 'Shipped but title not transferred on Sales'
                    END
                   )
           WHEN pss.section_name IN
                         ('Shipped TT', 'Stock TT', 'Shipped IN', 'Stock IN')
              THEN (CASE
                       WHEN pss.contract_type = 'P'
                          THEN 'Inventory Purchase'
                       ELSE 'Inventory Sales'
                    END
                   )
        END
       ) position_sub_type,
       pss.gmr_ref_no || '- ' || pss.stock_ref_no contract_ref_no,
       'NA' external_ref_no, NULL issue_date, 'NA' cp_id, 'NA' cp_name,
       'NA' incoterm, 'NA' payment_term, cm.cur_code group_currency,
       pss.base_cur_code corp_currency,
         (CASE
             WHEN pss.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * pss.stock_dry_qty contract_quantity,
       pss.qty_unit contract_quantity_uom,
         (CASE
             WHEN pss.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * NVL (pss.stock_dry_qty, 0)
       * NVL (ucm.multiplication_factor, 0) quantity_in_base_uom,
       0 quantity_in_lots, 0 contract_price,
       pss.contract_price_string contract_price_unit,
       pss.net_contract_value_in_base_cur net_contract_value,
       0 net_contract_premium_value, 0 net_sc_cost,
       0 contract_treatment_charge, 0 contract_refining_charge,
       0 contract_penalty_charge, 'NA' valuation_instrument_id,
       'NA' valuation_instrument, 'NA' derivative_def_id,
       'NA' derivative_def_name, 'NA' valuation_month, NULL value_date,
       pss.net_contract_value_in_base_cur total_cost_in_m2m_currency,
       pss.base_cur_code m2m_currency,
       pss.net_contract_value_in_base_cur expected_cog_net_sale_value,
       0 m2m_settlement_price, pss.m2m_price_string settlement_price_unit,
       'NA' valuation_city_id, 'NA' valuation_city, 'NA' valuation_country_id,
       'NA' valuation_country, 0 m2m_basis,
       NVL (m2m_loc_diff_premium, 0) m2m_loc_incoterm_deviation,
       0 m2m_quality_premium, 0 m2m_product_premium,
       NVL (pss.m2m_treatment_charge, 0) m2m_treatment_charge,
       NVL (pss.m2m_refining_charge, 0) m2m_refining_charge,
       NVL (pss.m2m_penalty_charge, 0) m2m_penality_charge,
       0 net_settlement_price,
       pss.net_m2m_amount_in_base_cur market_value_in_val_ccy,
       pss.base_cur_id market_value_cur_id,
       pss.base_cur_code market_value_cur_code,
       NVL (pss.prev_day_pnl_in_base_cur, 0) prev_day_unr_pnl_in_base_cur,
       NVL (pss.pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       NVL (pss.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       pss.base_cur_id base_cur_id, pss.base_cur_code base_cur_code,
       pss.prod_base_qty_unit base_quantity_uom
  FROM psue_phy_stock_unrealized_ele@eka_eoddb pss,
       ak_corporate@eka_eoddb akc,
       cpc_corporate_profit_center@eka_eoddb cpc,
       cm_currency_master@eka_eoddb cm,
       gcd_groupcorporatedetails@eka_eoddb gcd,
       tdc_trade_date_closure@eka_eoddb tdc,
       ucm_unit_conversion_master@eka_eoddb ucm,
       pdm_productmaster@eka_eoddb pdm
 WHERE pss.process_id = tdc.process_id
   AND pss.corporate_id = tdc.corporate_id
   AND pss.corporate_id = akc.corporate_id
   AND pss.profit_center_id = cpc.profit_center_id
   AND akc.groupid = gcd.groupid
   AND gcd.group_cur_id = cm.cur_id(+)
   AND ucm.from_qty_unit_id = pss.qty_unit_id
   AND ucm.to_qty_unit_id = pss.prod_base_qty_unit_id
   AND pss.product_id = pdm.product_id
   AND ucm.is_active = 'Y'
   AND tdc.process = 'EOD'
   AND pss.price_type_id <> 'Fixed' ;
/
CREATE OR REPLACE VIEW V_CASH_FLOW AS 
--
-- 1. Invoices - Includes all invoices and credit / debit notes to the extent not paid
--
SELECT 'Invoices to extent not paid' section_name,
       iss.corporate_id,
       akc.corporate_name,
       nvl(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
       nvl(cpc.profit_center_short_name, cpc1.profit_center_short_name) profit_center,
       akc.base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       (CASE
           WHEN nvl(pcm.purchase_sales, 'NA') = 'P' THEN
            'Purchase'
           WHEN nvl(pcm.purchase_sales, 'NA') = 'S' THEN
            'Sales'
           ELSE
            'NA'
       END) contract_type,
       'Invoices' position_type,
       CASE
           WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit') AND
                sign(iss.total_amount_to_pay) = 1 AND pcm.purchase_sales ='P' THEN    'Outflow'
                WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit') AND
                sign(iss.total_amount_to_pay) = 1 AND pcm.purchase_sales ='S' THEN 'Inflow'                 
                WHEN (iss.invoice_type = 'Commercial' OR  iss.invoice_type ='DebitCredit') AND
                sign(iss.total_amount_to_pay) = -1 AND pcm.purchase_sales ='P' THEN    'Inflow'
                WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit') AND
                sign(iss.total_amount_to_pay) = -1 AND pcm.purchase_sales ='S' THEN    'Outflow'
           WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Recieved' THEN 'Outflow'
           WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Raised' THEN 'Inflow'
           WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='P' THEN  'Outflow' 
           WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='S' THEN  'Inflow' 
         --  WHEN nvl(pcm.purchase_sales, 'NA') = 'P' THEN 'Outflow'
         --  WHEN nvl(pcm.purchase_sales, 'NA') = 'S' THEN 'Inflow'
       END payable_receivable,
       nvl(iss.invoice_ref_no, 'NA') AS contract_ref_no,
       (CASE
           WHEN iss.invoice_type_name = 'AdvancePayment' THEN
            'Commercial'
           ELSE
            nvl(iss.invoice_type, 'NA')
       END) invoice_type,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code invoice_cur_code,
       round(iss.total_amount_to_pay, 4) * nvl(iss.fx_to_base, 1) *
       CASE
       WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit')  THEN    1
       WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Recieved' THEN -1
       WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Raised' THEN 1
       WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='P' THEN  -1 
       WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='S' THEN  1 
    --   WHEN nvl(pcm.purchase_sales, 'NA') = 'P' THEN -1
    --  WHEN nvl(pcm.purchase_sales, 'NA') = 'S' THEN 1
   END invoice_amount_in_base_cur,
       round(iss.total_amount_to_pay, 4) *
       CASE
       WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit') THEN    1
       WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Recieved' THEN -1
       WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Raised' THEN 1
       WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='P' THEN  -1 
       WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='S' THEN  1 
  --       WHEN nvl(pcm.purchase_sales, 'NA') = 'P' THEN -1
  --     WHEN nvl(pcm.purchase_sales, 'NA') = 'S' THEN 1
   END invoice_amt,
       iss.invoice_issue_date activity_date,
       iss.payment_due_date cash_flow_date
FROM   is_invoice_summary            iss,
       cm_currency_master            cm_p,
       incm_invoice_contract_mapping incm,
       pcm_physical_contract_main    pcm,
       ak_corporate                  akc,
       cpc_corporate_profit_center   cpc,
       cpc_corporate_profit_center   cpc1,
       pcpd_pc_product_definition    pcpd,
       cm_currency_master            cm_akc_base_cur,
       css_corporate_strategy_setup  css
WHERE  iss.is_active = 'Y'
AND    iss.corporate_id IS NOT NULL
AND    iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
AND    incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
AND    iss.corporate_id = akc.corporate_id
AND    iss.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    iss.profit_center_id = cpc.profit_center_id(+)
AND    pcpd.profit_center_id = cpc1.profit_center_id(+)
AND    iss.invoice_cur_id = cm_p.cur_id(+)
AND    nvl(pcm.partnership_type, 'Normal') = 'Normal'
/*AND    'TRUE' = 
       (CASE WHEN iss.invoice_type_name = 'AdvancePayment' THEN 'TRUE' WHEN
        iss.invoice_type_name = 'Profoma' THEN 'FALSE' WHEN
        iss.invoice_type = 'DebitCredit' THEN 'TRUE'
        ELSE(CASE WHEN nvl(iss.invoice_type, 'NA') = 'Commercial' THEN 'TRUE' WHEN
              nvl(iss.invoice_type, 'NA') = 'Service' THEN 'TRUE' ELSE 'FALSE' END) END)
*/ and iss.invoice_type_name <> 'Profoma'
AND    cm_akc_base_cur.cur_id = akc.base_cur_id
AND    pcpd.strategy_id = css.strategy_id(+)
AND    iss.total_amount_to_pay <> 0

--
-- 2. OTC invoices 
-- 
UNION ALL
SELECT 'OTC invoices',
       dt.corporate_id,
       ak.corporate_name,
       dt.profit_center_id,
       cpc.profit_center_short_name,
       cm_akc_base_cur.cur_id base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       dt.strategy_id strategy_id,
       css.strategy_name,
       (CASE
           WHEN dt.trade_type LIKE '%Buy%' THEN
            'Purchase'
           ELSE
            'Sales'
       END) contract_type,
       'Invoices' position_type,
       (CASE
           WHEN dt.trade_type LIKE '%Buy%' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) inflow_outflow,
       dt.derivative_ref_no ref_no,
       nvl(dis.invoice_type,'NA') invoice_type,
       inv_cur.cur_id invoice_cur_id,
       inv_cur.cur_code invoice_cur_code,
       round((CASE
                 WHEN ak.base_cur_id = dis.invoice_cur_id THEN
                  1
                 ELSE
                  pkg_general.f_get_converted_currency_amt(dis.corporate_id,
                                                           dis.invoice_cur_id,
                                                           ak.base_cur_id,
                                                           SYSDATE,
                                                           1)
             END) * round(dis.amt_to_pay, 4) * (CASE
                 WHEN nvl(dis.received_raised_type, 'NA') = 'Raised' THEN
                  1
                 WHEN nvl(dis.received_raised_type, 'NA') = 'Received' THEN
                  -1
                 ELSE
                  1
             END),
             4) invoice_amount_in_base_cur,
       round(dis.amt_to_pay, 4) * (CASE
                                       WHEN nvl(dis.received_raised_type, 'NA') = 'Raised' THEN
                                        1
                                       WHEN nvl(dis.received_raised_type, 'NA') = 'Received' THEN
                                        -1
                                       ELSE
                                        1
                                   END),
       dis.issue_date activity_date,
       dis.payment_due_date cash_flow_date
FROM   dt_derivative_trade            dt,
       ak_corporate                   ak,
       cpc_corporate_profit_center    cpc,
       css_corporate_strategy_setup   css,
       cm_currency_master             inv_cur,
       dis_derivative_invoice_summary dis,
       fsh_fin_settlement_header      fsh,
       cm_currency_master             cm_akc_base_cur
WHERE  ak.corporate_id = dt.corporate_id
AND    cpc.profit_center_id = dt.profit_center_id
AND    css.strategy_id = dt.strategy_id
AND    inv_cur.cur_id = dis.invoice_cur_id
AND    dt.internal_derivative_ref_no = fsh.internal_derivative_ref_no
AND    fsh.fsh_id = dis.internal_settlement_ref_no
AND    dis.invoice_status = 'Active'
AND    fsh.is_deleted = 'N'
AND    dt.is_what_if = 'N'
AND    inv_cur.is_active = 'Y'
AND    css.is_active = 'Y'
AND    cpc.is_active = 'Y'
AND    ak.is_active = 'Y'
AND    cm_akc_base_cur.cur_id = ak.base_cur_id
--
-- 3. Currency Trades
--
UNION ALL
SELECT 'Currency Trades',
       ct.corporate_id,
       ak.corporate_name,
       ct.profit_center_id,
       cpc.profit_center_short_name,
       akc_cm.cur_id base_cur_id,
       akc_cm.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       crtd.trade_type contract_type,
       'Currency Trades' position_type,
       (CASE
           WHEN upper(crtd.trade_type) = 'BUY' THEN
            'Inflow'
           ELSE
            'Outflow'
       END) inflow_outflow,
       nvl(crtd.internal_treasury_ref_no,'NA') contract_ref_no,
       'NA' invoice_type,
       crtd.cur_id invoice_cur_id,
       crtd_cm.cur_code invoice_cur_code,
       round(crtd.amount, 4) * (CASE
                                    WHEN upper(crtd.trade_type) = 'BUY' THEN
                                     1
                                    ELSE
                                     -1
                                END) * ct.exchange_rate cash_flow_amount,
       round(crtd.amount, 4) * (CASE
                                    WHEN upper(crtd.trade_type) = 'BUY' THEN
                                     1
                                    ELSE
                                     -1
                                END),
       ct.trade_date activity_date,
       ct.payment_due_date cash_flow_date
FROM   ct_currency_trade            ct,
       ak_corporate                 ak,
       cm_currency_master           akc_cm,
       cpc_corporate_profit_center  cpc,
       cm_currency_master           cpc_cm,
       css_corporate_strategy_setup css,
       crtd_cur_trade_details       crtd,
       cm_currency_master           crtd_cm
WHERE  ct.corporate_id = ak.corporate_id
AND    ak.base_cur_id = akc_cm.cur_id
AND    ct.profit_center_id = cpc.profit_center_id
AND    ct.strategy_id = css.strategy_id(+)
AND    ct.internal_treasury_ref_no = crtd.internal_treasury_ref_no
AND    crtd.cur_id = crtd_cm.cur_id(+)
AND    cpc.profit_center_cur_id = cpc_cm.cur_id(+)
AND    upper(ct.status) = 'VERIFIED'
--
-- 4. Accruals - Expense accruals (remaining), income accrual (remaining)
--
UNION ALL
SELECT 'Accruals ',
       akc.corporate_id,
       akc.corporate_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_name profit_center_name,
       akc.base_cur_id,
       cm_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       cs.income_expense contract_type,
       'Accruals' position_type,
       (CASE
           WHEN cs.income_expense = 'Expense' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) payable_receivable,
       gmr.gmr_ref_no ref_no,
       'NA' invoice_type,
       cs.transaction_amt_cur_id invoice_cur_id,
       cm_cs_cur.cur_code invoice_cur_code,
       (CASE
           WHEN cm_base_cur.cur_id = cs.transaction_amt_cur_id THEN
            1
           ELSE
            pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                     cs.transaction_amt_cur_id,
                                                     cm_base_cur.cur_id,
                                                     SYSDATE,
                                                     1)
       END) * round(nvl(cs.transaction_amt, 0), 4) * (CASE
           WHEN cs.income_expense = 'Expense' THEN
            -1
           ELSE
            1
       END) invoice_amount_in_base_cur,
       round(nvl(cs.transaction_amt, 0), 4) *
       (CASE
            WHEN cs.income_expense = 'Expense' THEN
             -1
            ELSE
             1
        END) invoice_amount,
       cs.effective_date,
       cs.effective_date
FROM   cigc_contract_item_gmr_cost  cigc,
       cs_cost_store                cs,
       gmr_goods_movement_record    gmr,
       ak_corporate                 akc,
       cm_currency_master           cm_base_cur,
       pcpd_pc_product_definition pcpd,
       cpc_corporate_profit_center  cpc,
       css_corporate_strategy_setup css,
       cm_currency_master           cm_cs_cur,
       scm_service_charge_master scm
WHERE  cs.cog_ref_no = cigc.cog_ref_no
AND    cs.cost_type = 'Accrual'
AND    cigc.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    gmr.corporate_id = akc.corporate_id
AND    akc.base_cur_id = cm_base_cur.cur_id
AND    gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    pcpd.strategy_id = css.strategy_id
AND    cm_cs_cur.cur_id = cs.transaction_amt_cur_id
and    scm.cost_id = cs.cost_component_id
and    scm.cost_type ='SECONDARY_COST'
--
-- 5. Open Contracts(includes shipped title not transferred), title transferrred but not invoiced
--
UNION ALL
SELECT 'Open Contracts',
       mvf.corporate_id,
       mvf.corporate_name,
       mvf.profit_center_id,
       mvf.profit_center,
       mvf.base_cur_id,
       mvf.base_cur_code,
       mvf.strategy_id,
       mvf.strategy_name,
       (CASE
           WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
            'Purchase'
           ELSE
            'Sales'
       END) contract_type,
       nvl(mvf.contract_ref_no,'NA') ref_no,
       'Open Contracts' position_type,
       (CASE
           WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) inflow_outflow,
       'NA' invoice_type,
       NULL invoice_cur_id,
       mvf.m2m_currency invoice_cur_code,
       round((CASE
                 WHEN nvl(cm.cur_code, mvf.base_cur_code) = mvf.m2m_currency THEN
                  1
                 ELSE
                  pkg_general.f_get_converted_currency_amt(mvf.corporate_id,
                                                           mvf.market_value_cur_id,
                                                           mvf.base_cur_id,
                                                           SYSDATE,
                                                           1)
             END) * round(mvf.total_cost_in_m2m_currency, 4) * (CASE
                 WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
                  -1
                 ELSE
                  1
             END),
             4),
       round(mvf.total_cost_in_m2m_currency, 4) *
       (CASE
            WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
             -1
            ELSE
             1
        END),
       mvf.issue_trade_date activity_date,
       mvf.eod_date cash_flow_date
FROM   mv_fact_phy_unreal_fixed_price mvf,
       cpc_corporate_profit_center cpc,
       cm_currency_master          cm
WHERE  mvf.profit_center_id = cpc.profit_center_id
AND    mvf.base_cur_id = cm.cur_id(+)
AND    (mvf.corporate_id, mvf.eod_date) IN
       (SELECT eod.corporate_id,
                MAX(eod.as_of_date)
         FROM   eod_end_of_day_details eod
         WHERE  eod.processing_status IN
                ('EOD Processed Successfully',
                 'EOD Process Success,Awaiting Cost Entry')
         GROUP  BY eod.corporate_id)
AND    NOT EXISTS -- Not Invoiced Check
 (SELECT iss.corporate_id,
               iss.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               gmr.gmr_ref_no
        FROM   is_invoice_summary          iss,
               iid_invoicable_item_details iid,
               gmr_goods_movement_record   gmr
        WHERE  iss.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    iss.invoice_status = 'Active'
        AND    iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND    iss.corporate_id = mvf.corporate_id
        AND    instr(mvf.contract_ref_no, gmr.gmr_ref_no, 1) = 1)
--
-- 6. Base Metal Open Uninvoiced GMRs with Fixed Price (Base Metal)
--
UNION ALL
SELECT 'Fixed Price GMRs Base Metal' section_name,
       akc.corporate_id,
       akc.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_name,
       akc.base_cur_id base_cur_id,
       cm_base.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') contract_type,
       'Open Contracts' position_type,
       (CASE
           WHEN pcm.purchase_sales = 'P' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) recievable_payable,
       gmr.internal_gmr_ref_no,
       'NA' invoice_type,
       pum.cur_id invoice_cur_id,
       cm_pum.cur_code invoice_cur_code,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      SYSDATE,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   grd.qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ((nvl(grd.current_qty, 0) +
                                                   nvl(grd.release_shipped_qty,
                                                         0) -
                                                   nvl(grd.title_transfer_out_qty,
                                                         0))))),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) cashflow_amt_in_base_cur,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      SYSDATE,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   grd.qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ((nvl(grd.current_qty, 0) +
                                                   nvl(grd.release_shipped_qty,
                                                         0) -
                                                   nvl(grd.title_transfer_out_qty,
                                                         0))))),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) invoice_amt,
       pcm.issue_date activity_date,
       gmr.eff_date cashflow_date
FROM   gmr_goods_movement_record    gmr,
       pcm_physical_contract_main   pcm,
       pcdi_pc_delivery_item        pcdi,
       pci_physical_contract_item   pci,
       ak_corporate                 akc,
       grd_goods_record_detail      grd,
       pdm_productmaster            pdm,
       ppu_product_price_units      ppu,
       pum_price_unit_master        pum,
       cpc_corporate_profit_center  cpc,
       css_corporate_strategy_setup css,
       cm_currency_master           cm_base,
       cm_currency_master cm_pum
WHERE  NOT EXISTS -- Not Invoiced Check
 (SELECT iss.corporate_id,
               iss.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               gmr.gmr_ref_no
        FROM   is_invoice_summary          iss,
               iid_invoicable_item_details iid
        WHERE  iss.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    iss.invoice_status = 'Active'
        AND    iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
AND    grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
AND    pci.pcdi_id = pcdi.pcdi_id
AND    pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
AND    pcdi.item_price_type = 'Fixed'
AND    gmr.corporate_id = akc.corporate_id
AND    gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
AND    grd.product_id = pdm.product_id
AND    ppu.internal_price_unit_id = pcdi.item_price_unit
AND    ppu.price_unit_id = pum.price_unit_id
AND    grd.profit_center_id = cpc.profit_center_id
AND    grd.strategy_id = css.strategy_id
AND    akc.base_cur_id = cm_base.cur_id
AND    (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -   nvl(grd.title_transfer_out_qty, 0)) > 0
and    cm_pum.cur_id = pum.cur_id
and    pcm.contract_type ='BASEMETAL'

UNION ALL
--
-- 7. Open Contracts Fixed Price Basis (Base Metal)
--
SELECT 'Fixed Price Contracts Base Netal' section_name,
       akc.corporate_id,
       akc.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_name,
       cm_base.cur_id,
       cm_base.cur_code,
       css.strategy_id,
       css.strategy_name,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') contract_type,
       'Open Contracts' position_type,
       (CASE
           WHEN pcm.purchase_sales = 'P' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) recievable_payable,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no,
       'NA' invoice_type,
       NULL invoice_cur_id,
       cm_base.cur_code invoice_cur_code,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      SYSDATE,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   ciqs.item_qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ciqs.open_qty)),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) cashflow_amt_in_base_cur,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      SYSDATE,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   ciqs.item_qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ciqs.open_qty)),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END)  invoice_amt,
       pcm.issue_date activity_date,
       pcm.issue_date cashflow_date
FROM   pcm_physical_contract_main    pcm,
       pcdi_pc_delivery_item         pcdi,
       pci_physical_contract_item    pci,
       ciqs_contract_item_qty_status ciqs,
       ak_corporate                  akc,
       cpc_corporate_profit_center   cpc,
       pcpd_pc_product_definition    pcpd,
       cm_currency_master            cm_base,
       css_corporate_strategy_setup  css,
       pdm_productmaster             pdm,
       ppu_product_price_units       ppu,
       pum_price_unit_master         pum
WHERE  pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdi.pcdi_id = pci.pcdi_id
AND    pcdi.item_price_type = 'Fixed'
AND    pci.internal_contract_item_ref_no = ciqs.internal_contract_item_ref_no
AND    ciqs.open_qty > 0
AND    pcm.corporate_id = akc.corporate_id
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    akc.base_cur_id = cm_base.cur_id
AND    pcpd.strategy_id = css.strategy_id
AND    pcpd.product_id = pdm.product_id
AND    ppu.internal_price_unit_id = pcdi.item_price_unit
AND    ppu.price_unit_id = pum.price_unit_id
AND    pcm.contract_type ='BASEMETAL'
/

