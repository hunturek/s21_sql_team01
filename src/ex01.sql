WITH
  lr_currency_upd AS (
    SELECT
      balance.currency_id,
      balance.updated AS balance_upd,
      (SELECT currency.updated WHERE currency.updated > balance.updated) AS right_cur_upd,
      (SELECT currency.updated WHERE currency.updated < balance.updated) AS left_cur_upd
    FROM balance
    FULL JOIN currency ON balance.currency_id = currency.id
  ),
  balance_currency_upd AS (
    SELECT
      currency_id,
      balance_upd,
      CASE 
      WHEN (MAX(left_cur_upd) IS NOT NULL)
      THEN MAX(left_cur_upd)
      ELSE MIN(right_cur_upd)
      END res
    FROM lr_currency_upd
    GROUP BY 1, 2
  )
SELECT
  COALESCE(u.name, 'not defined') AS name, 
  COALESCE(u.lastname, 'not defined') AS lastname, 
  c.name AS currency_name,
  c.rate_to_usd * b.money AS currency_in_usd
FROM "user" u
FULL JOIN balance b ON u.id=b.user_id
JOIN currency c ON b.currency_id=c.id
JOIN balance_currency_upd bc ON b.updated = bc.balance_upd AND c.id = bc.currency_id AND c.updated = bc.res
ORDER BY 1 DESC, 2, 3;