ALTER TABLE GMR_GOODS_MOVEMENT_RECORD DROP CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE;
ALTER TABLE AGMR_ACTION_GMR DROP CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE;

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD (
    CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE CHECK (TOLLING_GMR_TYPE IN ('None Tolling','Mark For Tolling','Received Materials','Output Process','Process Activity','Input Process','Pledge','Financial Settlement','Return Material'))
);

ALTER TABLE AGMR_ACTION_GMR ADD (
  CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE
  CHECK (TOLLING_GMR_TYPE IN ('None Tolling','Mark For Tolling','Received Materials','Output Process','Process Activity','Input Process','Pledge','Financial Settlement','Return Material'))
);