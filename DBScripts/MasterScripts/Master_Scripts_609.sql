------------------------------------------------------------------------------------------
--Corporate list filter (Filter shows all Active corporates except the logged in Corporate
------------------------------------------------------------------------------------------

insert into gff_general_filter_fields
   (field_id, field_name, tag_name, is_combo_box)
 values
   ('GFFCDC002', 'Corporate List', 'eka:dropDown', 'N');

insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00009', 'servicekey');
   
insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00010', 'fieldname');
   
insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00011', 'ismandatory');
   
insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00012', 'usedfor');
   
insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00013', 'formname');
   
insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00014', 'taborder');

insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00015', 'removeSelect');
   
insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00016', 'dynamicSelectVal');
   
insert into rfp_rfc_field_parameters
   (field_id, parameter_display_seq, parameter_id, tag_attribute_name)
 values
   ('GFFCDC002', 1, 'RFPC00017', 'attributeone');
   
commit;