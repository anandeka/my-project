update rfc_report_filter_config rfc
set rfc.is_mandatory = 'N'
where rfc.label_id in ('RFC362PHY06','RFC84PHY03','RFC225PHY04','RFC211PHY07','RFC360PHY02');
commit;
