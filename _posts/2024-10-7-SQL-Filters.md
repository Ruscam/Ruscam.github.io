---
title: Applying Filters to SQL Queries
date: 2024-10-07
categories: [Introduction Guide]
tags: [SQL, queries, filter, data]
---
# Overview
This reference guide will cover acquiring information from a database by running SQL queries and refining query results with logical operators
# Retrieve after hours failed login attempts
`SELECT * FROM log_in_attempts WHERE login_time > '18:00' AND success = FALSE;`
![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXeXh2rcsuiRGiM4APp-1hP-4mdYMgDSX1Iyt-qyju6GGXQ0YdYPxJHEQ6vlgqjMgzvZabYgR4LkySYVa3u2uIufGeWy645JkAiIkItXgZ2ULHfJJB1Rr_YVlQKrWEaJJ8oshSFefjRAn0fXfS9zMb6zh91mwUuMt4wBNRZCRA?key=oNWVfYJosdK0m4a4TTeAnA)
Note: the terminal emulation was having trouble and cut off the command after `COUNT(*)`

`SELECT COUNT(*) FROM log_in_attempts WHERE login_time > '18:00' AND success = FALSE`

Logical operators such as `AND`, `OR`, and `NOT` can all be used to filter results. These behave the same a Boolean operators in other programming languages.
- `AND`: both conditions must be true for the overall conditional to be true
- `OR`: either one or both conditions can be true for the overall conditional to evaluate as true
- `NOT`: will inverse the logical state of the conditional (true becomes false, and false becomes true)

In SQL, dates are their own data type. Dates are written in the international standard YYYY-MM-DD and do not use quotations around them as they are not strings. Mathematical operators like `=` (equals), `<` (less than), `>` (greater than), `<=` (less than or equal to), and `>=` (greater than or equal to) can be used on dates.
# Retrieve login attempts on specific dates
`SELECT * FROM log_in_attempts WHERE login_date = '2022-05-09' OR login_date = '2022-05-08';`

This queries the database to return everything from the `log_in_attempts` table that have dates on either 2022-05-08 or 2022-05-09.

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXeIa28TcUPj5luPi30-rNMC6fZT7b7ya5Yb799To6GLULe9eiroWV5AozWHlGSWcpZXZGRB9SVsPaOhFmd9rojw-1x_JQBfvHmTPYAzHNaY7VieHb-McOAkl2lUiinAvZxOsSoYz7O4XMQiyM4rxXMVNcMEmVAkzpjZLu_-Gg?key=oNWVfYJosdK0m4a4TTeAnA)

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXe5CiUedLyzGUcqrpOSZA0Ikn70ryiTHrdfKXWUhBe7_TS0y_Vs8fThSzTUgU3eJELlt_HRe4ZQRHqjuUbljNjWdlZCIZcnDtG_C0kHGjVBkzRzUpKcBeor1T-FOaaHL7IAZDmlJxdgk4W-ek9ajNxQ6T8PosrJaxxibmj7?key=oNWVfYJosdK0m4a4TTeAnA)

# Retrieve login attempts outside of Mexico
`SELECT * FROM log_in_attempts WHERE NOT country LIKE 'MEX%';`

This query returns everything from the log_in_attempts table that doesn’t have a country that begins with “MEX”.

In SQL, the `LIKE` operator will be similar to those who know a little bit of REGEX. It matches strings based on symbols. In the example above, `MEX%` uses the `%` wildcard. Wildcards are used to represent potentially substituted characters:

- `%` The percent sign can match any number of characters, including none
- `_` The underscore can match exactly one character

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXevD6OgIS2LmYxLXSajHJX_JVGMpSPjwTVZ0dJ0cj2GfJYb6EcXxCbP841qgFm6a5wVIvR4JcC3LCNkhXWycUP5yR6HIltfBZmkGqtPGkVnPOFe-cRGakDKhqsEDsFJe02hgOHm_bL27FV_1y0KEud2FVs7ksio9yQcWU0V?key=oNWVfYJosdK0m4a4TTeAnA)

# Retrieve employees in Marketing
`SELECT *  FROM employees;`

This query returns everything in the employees table. The employees table has a column for employee id, device_id, username, department, and office.

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXenX4TG_nq1RYCujtTLYNGMQMhHJfZyU775JbOgYFavdSMY8LlI9whYEV7ickXuFRW7jfK264VZJNW1F3R_2MX7C-hJ6ux1J91jDBhGWryDDHMkAcJhVxG5APhCoYfcaBtTIPMKQ_kLZO6Zh4kUZI9CCXB5swuWrQV-m_UT2w?key=oNWVfYJosdK0m4a4TTeAnA)

`SELECT * FROM employees WHERE department = 'Marketing' AND office LIKE 'EAST%';`

This query returns everything from the employee table that is in either the marketing department and that has an office that begins with the string “EAST”

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXczZJNHBNf-eoQZgVzybIpbzcjXdUriJ7oxOSu0RSRCHtSeH69gEHJ3nBCR6BYOxar3yanRhh1bttF-FqVjj9tp65WIo5MojTywQiLFVXP_BoSgQ7quu314IxNqChYA7gYQYAqVC1OTTTA2ZA14yH-kHhrPrX0Pw9ArFHPD?key=oNWVfYJosdK0m4a4TTeAnA)

# Retrieve employees in Finance or Sales
`SELECT * FROM employees WHERE department = 'Finance' OR department = 'Sales';`

This query returns everything from the employees table that has either “Finance” or “Sales” in the department column.

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXfw6OsYuIYiq7sS0i4WYeQMSQtlu_MqB5lBZp0jsW5EcfekxhO-dT8mGsK8VTOz4zDiGFBDjgogpr2QQh2YruPO7zBmTweLhl_DGcNCWWH25xl5wRzJ_1V_44QVmPIOvz3L5RBNQc0kc0rFuTbrBrmcTjN_tY0_HMMnEyhRRA?key=oNWVfYJosdK0m4a4TTeAnA)

# Retrieve all employees not in IT
`SELECT * FROM employees WHERE NOT department = 'Information Technology';`

This query returns everything from the employees table where the department is not “Information Technology”

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXdbfcLtMzhMtmlXl5z7cg9UZDBmEbcViEtJnBcF3qCxXmfZGWTkHKWXHE0Jq2AB7gzL0fbu0GFRmo-z28-9QnF8cATXLAl8xPJdZa2_DdU6jMmbJEy2pjQybiF5LitKJWAJE4Tss8CXgVoiGiW8ihbzGb6NtGiMrrG2_w1a?key=oNWVfYJosdK0m4a4TTeAnA)

# Summary
SQL queries can be used to find and filter results from a database. Operators like `AND`, `OR`, `NOT` can perform Boolean arithmetic to filter results. Pattern matching can be achieved with `LIKE`. Dates can be used with comparator operators like `>`, `<`, `=`, `>=`, `<=`. When combined, these operators allow security analysts to pull out exactly what they need from SQL databases.

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXeRoamKxiKc1kMD2QNPjA7Sz1TC5za8fCSvrI3FSYhsRrdqex2MC5PW5CXZD2Ptf1gkFEjGW7GR3EgzlpulWE9gsZ96qiAlwJsVMMUO2ZQTDbGdNlpwLA8wj51ohjtFasLaBWG6YEbHz7Z7osZrDpS0u7abH0uLaAPoOLwm?key=oNWVfYJosdK0m4a4TTeAnA)

