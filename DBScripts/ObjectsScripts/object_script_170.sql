ALTER table GPAH_GMR_PRICE_ALLOC_HEADER drop column TOTAL_QTY_ALLOCATED_QTY;
ALTER table GPAH_GMR_PRICE_ALLOC_HEADER add( TOTAL_ALLOCATED_QTY NUMBER(25,10));