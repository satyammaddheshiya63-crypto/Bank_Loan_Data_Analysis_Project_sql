USE Joining;
SELECT * FROM Bank_Loan;


# Find the total number of loans, total loan amount, and average interest rate for each loan type
SELECT Loan_Type, COUNT(*) AS Total_Loans,
SUM(Loan_Amount) AS Total_Loan_Amount,
ROUND(AVG(CAST(Interest_Rate AS Double)), 2) AS Avg_Int_Rate
FROM Bank_Loan
GROUP BY Loan_Type
ORDER BY Total_Loan_Amount DESC;

-- Insight : Loan Distribution Analysis according to each loan type

/* Classify customers into risk categories using credit score:
Excellent → Credit Score >= 750
Good → 650–749
Average → 550–649
Poor → Below 550
Then find: Total customers, Total loan amount, Default percentage for each category. */

WITH Risk_Category AS 
(
		SELECT Customer_Id, Loan_Amount, Defaulted, Credit_Score,
        CASE
			WHEN Credit_Score >= 750 THEN 'Excellent'
			WHEN Credit_Score BETWEEN 650 AND 749 THEN 'Good'
            WHEN Credit_Score BETWEEN 550 AND 649 THEN 'Average'
            ELSE 'Poor'
		END AS Risk_Level
        FROM Bank_Loan
)
		SELECT Risk_Level, COUNT(Customer_Id) AS Total_Customer, 
        SUM(Loan_Amount) AS Total_Loan_Amount,
        SUM(Defaulted) AS Total_Defaluts,
        (SUM(Defaulted) * 100) / COUNT(Customer_id) AS Default_Percentage
        FROM Risk_Category
        GROUP BY Risk_Level
        ORDER BY Default_Percentage DESC;

/* insight -- This analysis helps bank : identify risky customer, reduce bad loans, 
			  improve loan approval strategy */


/* Find the top 5 customers who have taken the highest total loan amount.
Their income
Credit score
Rank */

WITH Customer_loan AS
(
	SELECT Customer_ID, Annual_Income, Credit_Score,
    SUM(Loan_Amount) AS Total_Loan_Amount
    FROM Bank_Loan
    GROUP BY 1, 2, 3
),
Customer_Rank AS
(
		SELECT *,
        RANK() OVER (ORDER BY Total_Loan_Amount DESC) AS Customer_Rank
        FROM Customer_Loan
)
	SELECT Customer_ID, Annual_Income, Credit_Score, Total_Loan_Amount, Customer_Rank
    FROM Customer_Rank
    WHERE Customer_Rank <= 5;
    
SELECT *
FROM (
		SELECT Customer_Id, Annual_Income, Credit_Score,
        SUM(Loan_Amount) AS Total_Loan_Amount,
        RANK() OVER (ORDER BY SUM(Loan_Amount) DESC) AS Customer_Rank
        FROM Bank_Loan
        GROUP BY 1, 2, 3
        ) t
WHERE Customer_Rank <= 5;

SELECT Customer_Id, Annual_Income, Credit_Score,
SUM(Loan_Amount) AS Total_Loan_Amount,
RANK() OVER (ORDER BY SUM(Loan_Amount) DESC) AS Customer_Rank
FROM Bank_Loan
GROUP BY 1, 2, 3
LIMIT 5;

/* Insights : Top 5 customers who have taken highest loan amount 

/* Analyze which education level and employment status combination has the highest default rate.
Education level, Employment status, Total customers, Total defaults, Default percentage */

WITH Customer_Default AS
(
	SELECT Education_Level, Employment_Status, Customer_Id, Defaulted
	FROM Bank_Loan
), 
Default_Analysis AS
(
	SELECT Education_Level, Employment_Status,
    COUNT(Customer_ID) AS Total_Customers,
    SUM(Defaulted) AS Total_Defaults,
    (SUM(Defaulted) * 100) / COUNT(Customer_Id) AS Default_Percentage
    FROM Customer_Default
    GROUP BY Education_Level, Employment_Status
)
	SELECT Education_Level, Employment_Status, Total_Customers, Total_Defaults,
    Default_Percentage
    FROM Default_Analysis
    ORDER BY Default_Percentage DESC;


SELECT Education_Level, Employment_Status, 
COUNT(Customer_Id) AS Total_Customers, 
SUM(Defaulted) AS Total_Default,
(SUM(Defaulted) * 100) / COUNT(Customer_ID) AS Default_Percentage
FROM Bank_Loan
GROUP BY 1, 2
ORDER BY Default_Percentage DESC;

SELECT *
FROM (
		SELECT Employment_Status, Education_Level,
        COUNT(Customer_Id) AS Total_Customers,
        SUM(Defaulted) AS Total_Defaults,
        (SUM(Defaulted) * 100) / COUNT(Customer_Id) AS Default_Percentage
        FROM Bank_Loan
        GROUP BY 1, 2
        ) t;
        
/* Insights : Unemployed with graduate is the most default percent
			it means higher percent = higher financial risk, bad loans , repayment failure

/* Monthly Installment Burden Analysis
Calculate what percentage of annual income is being spent on loan installments
Then create burden Categories:
Low burden, Medium burden, High burden
After that analyze: Total customers, average installment,
total defaults, default percentage for each category */

WITH Installment_Analysis AS
(
	SELECT Customer_Id, Annual_Income, Monthly_Installment, Defaulted,
    ROUND((CAST(Monthly_Installment AS Double) * 12 * 100), 2) / Annual_income AS Installment_Percent
    FROM Bank_Loan
),
Burden_Category AS
(
	SELECT *,
		CASE
			WHEN Installment_Percent > 20 THEN 'Low Burden'
            WHEN Installment_Percent BETWEEN 20 AND 40 THEN 'Medium Burden'
            ELSE 'High Burden'
		END AS Burden_Level
	FROM Installment_Analysis
)
	SELECT Burden_Level,
    COUNT(Customer_Id) AS Total_Customers,
    ROUND(AVG(CAST(Monthly_Installment AS Double)), 2) AS Avg_installment,
    SUM(Defaulted) AS Total_Defaults,
    SUM(Defaulted) * 100 / COUNT(Customer_Id) AS Default_Percent
    FROM Burden_Category
    GROUP BY Burden_Level
    ORDER BY Default_Percent DESC;
    
/* Insights : High burden level has the lowest default percent with 6.67%
			  It means Avg monthly installment is paid minimum rather than low burden 
              and also in high burden'customers are less than low burden. */
    
/* Loan approval trend by age group
Create age groups : 18-25, 26-35, 36-50, 50+
Then find : Total application, approved loans, reject loans, approval percentage for each age group */

WITH Age_Group_data AS
(
	SELECT Customer_id, Loan_Status, Age,
    CASE
		WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
	END AS Age_Group
    FROM Bank_Loan
) 
	SELECT Age_Group,
    COUNT(Customer_Id) AS Total_Application,
    SUM(
		CASE
			WHEN Loan_Status = "Approved" THEN 1
            ELSE 0
		END) AS Approved_Loan,
	SUM(
		CASE
			WHEN Loan_Status = "Rejected" THEN 1
            ELSE 0
		END) AS Rejected_Loan,
	SUM(
		CASE
			WHEN Loan_Status = "Approved" THEN 1
            ELSE 0
		END) * 100 / COUNT(Customer_Id) AS Approved_Percentage
	FROM Age_Group_Data
	GROUP BY Age_Group
    ORDER BY Approved_Percentage DESC;
    
/* Insights : Second Lower Age Group (26-35) have the highest loan approved with 86.67% 
			  likely due to stable income and stroger credit history
			  









