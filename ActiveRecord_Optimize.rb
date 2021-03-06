# 这几天对项目MySQL　慢查询优化的总结
１. N+1 问题
很多问题都是N+1问题导致的，这种问题使用includes　一般都能有效的解决。在使用includes时，其实执行的是两条sql语句查询。
第一句一般是根据外键，找到满足条件的id,　第二句再根据第一句得到的id数组结果进行in查询。　如果这个id数据结果是在5000以内,
使用includes这样解决N+1问题都是很高效的。如果，id数组的结果超过了5000甚至是１w多，这时候的查询往往会非常慢。可以选择left join连接
表的方式，或者union、子查询等比较执行速度，得到最好的优化方法。
我就遇到了得到的id数组为２w多，使得用left　join　的方法效率更好

２. 正确的姿势的创建索引
如果数据库有重复的索引，请删除一个。在优化时，遇到一个表中两个一样作用的索引，只是索引名字不同，在删除其中一个索引后，查询速度立马正常了

尽量使用联合索引，比单个索引效率更改

对> < 比较的where　的查询，对这个字段建立索引，速度明显加快

order by field 也会用到索引，其中的一个优化就是，对order by field　的field创建了联合索引，并且放在最后，速度也快了几十倍

在某个查询想取第一个记录时, 使用take 或 limit(1)　代替　first　，速度会变快。
email = current_company.customers.where("email like ?", "#{ip}\_%\_#{company_id}@temp.com").try(:first).try(:email)
email = current_company.customers.where("email like ?", "#{ip}\_%\_#{company_id}@temp.com").take.try(:email)
使用first　需要16s, 使用take　用了0.01s　来看这两个sql语句：
SELECT `customers`.* FROM `customers` WHERE  `customers`.`company_id` = 13300 AND (email like "119.57.115.195_%_13300@temp.com") ORDER BY `customers`.`id` ASC LIMIT 1;
SELECT `customers`.* FROM `customers` WHERE  `customers`.`company_id` = 13300 AND (email like "119.57.115.195_%_13300@temp.com") LIMIT 1;
first其实用到了order by　id　所以,　没用到company_id,email的联合索引,使得在like查询上耗费了大量时间

３．　使用　explain　进行分析,　能给予你一个好的解决思路

count(*)　是一种更好的选择。　当　count(*) from tables 效率最高。　count(*) from tables where 会进行全表的扫描,　所以最好给
where 的字段建立索引

４．另一种思路
if　customers.pluck(:email).uniq.include? content
if customers.where(email: content).plesent? 用这种方法直接查是否有这个邮件，只查row = 1 ，耗时 0.05s 以内，而且不耗内存，第一种方式产生的数组有可能消耗大量内存
present? 方法还可以用　exists?代替，速度又会更快一点
