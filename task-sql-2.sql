--Написать 3 различных SQL-запроса, которые рассчитывают количество уникальных пользователей (user_id),
-- которые совершали событие click_go_to_sberbank и событие click_link_part 
--за период с 2022-09-12' по '2022-09-22', включительно

--вариант 1 (через джойн таблицы на себя)

SELECT COUNT(DISTINCT e1.user_id)
FROM events AS e1
INNER JOIN events AS e2 ON e1.user_id = e2.user_id
WHERE to_timestamp(e2.timestamp::bigint / 1000) ::date BETWEEN '2022-09-12' AND '2022-09-22'
  AND (e1.event_action LIKE 'click_go_to_sberbank' AND e2.event_action LIKE 'click_link_part');
  

--вариант 2 (через подзапрос)

SELECT COUNT(DISTINCT a.user_id)
FROM
(SELECT *
 FROM events
 WHERE to_timestamp(timestamp::bigint / 1000) ::date BETWEEN '2022-09-12' AND '2022-09-22'
   AND event_action LIKE 'click_go_to_sberbank') AS a
INNER JOIN events AS e ON a.user_id = e.user_id
WHERE e.event_action LIKE 'click_link_part';
  

--вариант 3 (через вложенные GROUP BY)

WITH b AS
(
  SELECT user_id, event_action
  FROM events
  WHERE to_timestamp(timestamp::bigint / 1000) ::date BETWEEN '2022-09-12' AND '2022-09-22'
      AND event_action IN ('click_link_part', 'click_go_to_sberbank')
  GROUP BY user_id, event_action
), 

c AS
(
  SELECT user_id
  FROM b
  GROUP BY user_id
  HAVING COUNT(event_action) = 2
)

SELECT COUNT(*)
FROM c;
