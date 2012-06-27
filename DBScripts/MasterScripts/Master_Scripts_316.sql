update RFC_REPORT_FILTER_CONFIG rfc
set RFC.IS_MANDATORY = 'Y'
where rfc.label_id in ('RFC251PHY02','RFC251PHY03');
commit;