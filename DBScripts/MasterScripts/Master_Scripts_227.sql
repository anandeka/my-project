UPDATE rfc_report_filter_config rfc
   SET rfc.is_mandatory = 'N'
 WHERE rfc.REPORT_ID = '235'
 AND rfc.LABEL_ID = 'RFC235PHY02';
 COMMIT;
 