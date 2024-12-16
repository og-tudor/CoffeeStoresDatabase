CREATE PROCEDURE GetCoffeeStoresRevenue
AS
    BEGIN
        SELECT cs.store_name AS 'Coffee Store',
               l.city AS 'City',
               cs.revenue_goal AS 'Revenue Goal'


        FROM CoffeeStores cs
            JOIN Locations l ON cs.location_id = l.location_id

    end;

EXECUTE GetCoffeeStoresRevenue;