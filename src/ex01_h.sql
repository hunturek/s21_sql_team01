WITH new_dates AS (
  SELECT b.user_id, b.money, b.currency_id,
  CASE
    WHEN (SELECT MAX(c.updated) FROM currency c WHERE b.currency_id=c.id AND c.updated<=b.updated) IS NOT NULL
    THEN (SELECT MAX(c.updated) FROM currency c WHERE b.currency_id=c.id AND c.updated<=b.updated)
    ELSE (SELECT MIN(c.updated) FROM currency c WHERE b.currency_id=c.id AND c.updated>b.updated)
  END AS real_updated
  FROM balance b
)
SELECT COALESCE(u.name, 'not defined') AS name,
       COALESCE(u.lastname, 'not defined') AS lastname,
       c.name AS currency_name,
       n_d.money * c.rate_to_usd AS currency_in_usd
FROM new_dates n_d
     JOIN currency c ON n_d.real_updated=c.updated AND n_d.currency_id=c.id
LEFT JOIN "user" u ON n_d.user_id=u.id
ORDER BY name DESC, lastname, currency_name;
