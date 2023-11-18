WITH last_currency AS(
	SELECT *
	FROM currency
	WHERE updated IN(
		SELECT MAX(updated)
		FROM currency
		GROUP BY name
	)
),

volume AS (
	SELECT user_id, type, SUM(money) AS vol
	FROM balance
	GROUP BY 1,2
	ORDER BY 1
)

SELECT DISTINCT COALESCE(u.name, 'not defined') AS name, 
	   COALESCE(u.lastname, 'not defined') AS lastname,
	   b.type, 
	   v.vol AS volume, 
	   COALESCE(c.name, 'not defined') AS currency_name, 
	   COALESCE(c.rate_to_usd, 1) AS last_rate_to_usd, 
	   COALESCE(ROUND(v.vol * c.rate_to_usd), v.vol) AS total_volume_in_usd
FROM "user" u
FULL JOIN balance b ON u.id=b.user_id
FULL JOIN last_currency c ON b.currency_id=c.id	
FULL JOIN volume v ON v.type=b.type AND b.user_id=v.user_id
ORDER BY 1 DESC, 2, 3;
