alter table poud_phy_open_unreal_daily add is_approved char(1);
alter table poue_phy_open_unreal_element add is_approved char(1);
alter table poud_phy_open_unreal_daily add CONTRACT_STATUS varchar2(20);
alter table poue_phy_open_unreal_element add CONTRACT_STATUS varchar2(20);