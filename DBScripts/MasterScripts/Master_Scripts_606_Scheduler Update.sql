/* Formatted on 2013/06/19 17:08 (Formatter Plus v4.8.8) */

UPDATE jd_job_details jd
   SET jd.job_criteria =
          '{
  "asOfDate": "29-May-2013",
  "corporateId": "BLD",
  "isAnyDayPricing": true,
  "isAveragePricing": true,
  "priceProcessType": "QEP",
  "isScheduled": true
}'
 WHERE jd.job_id = 1;

UPDATE jd_job_details jd
   SET jd.job_criteria =
          '{
  "asOfDate": "29-May-2013",
  "corporateId": "BLD",
  "priceProcessType": "FEP",
  "isScheduled": true
}'
 WHERE jd.job_id = 2;

UPDATE jd_job_details jd
   SET jd.job_criteria =
          '{
  "asOfDate": "25-May-2013",
  "corporateId": "BLD",
  "priceProcessType": "AVG_PP",
  "isScheduled": true
}'
 WHERE jd.job_id = 3;