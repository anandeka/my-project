UPDATE ets_event_type_setup ets
   SET ets.action_url = '/metals/loadListOfDeliveryItems.action?gridId=LODI'
 WHERE ets.event_type_id IN ('ETS-PHY-2', 'ETS-PHY-3');