/* Formatted on 2012/12/13 16:18 (Formatter Plus v4.8.8) */
UPDATE axm_action_master axm
   SET axm.is_continuous_middle_no_req = 'N'
 WHERE axm.action_name IN
          ('Cancel Price Fixation', 'Cancel Vessel Fixation',
           'CancelPriceFinlization', 'Create Hedge Correction',
           'Create Price Fixation', 'Create Vessel Fixation',
           'CreatePriceFinlization', 'Final Price Fixation',
           'Modify Vessel Fixation', 'Partial Price Fixation',
           'Qty Exposure Process', 'Run Price Process')