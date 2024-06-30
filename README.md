# Correlation Analysis of Mask Mandates and COVID-19 Hospitalization Rates

This project utilizes historical data from The Covid Tracking Project by The Atlantic to explore potential correlations between mask-wearing mandates and hospitalization rates due to COVID-19 across several U.S. states. By leveraging SQL for detailed data manipulation and analysis, the project aims to understand if states with mask mandates experienced statistically different hospitalization trends compared to those without. Findings from this analysis could provide valuable insights into the effectiveness of public health policies during the pandemic.

## Technical Description

#### Data Collection

The data for this project was sourced primarily from [The COVID Tracking Project at The Atlantic](https://covidtracking.com/data) providing detailed records of COVID-19 cases and hospitalizations between Mar-2020 and Mar-2021. Additional data regarding mask-wearing policies were incorporated from a [New York Times dataset](https://static01.nyt.com/images/2021/08/05/us/cdc-mask-guidance-states-promo-1628210238731/cdc-mask-guidance-states-promo-1628210238731-superJumbo-v53.png), which documented state-level mask mandates over time.

#### SQL Queries and Analysis

The core of the data analysis was conducted using SQL, chosen for its robustness in handling and querying large datasets. Key SQL techniques used include:

- **Common Table Expressions (CTEs)**: Utilized to segment the data weekly and compute hospitalization rates per 1,000,000 people, enhancing the readability and modularity of the SQL queries.
- **Aggregate Functions**: To derive minimum, maximum, and average values which were crucial in understanding the range and average of hospitalizations over time.

Example of a primary SQL query used:

```sql
WITH Hosp1 AS (
    SELECT strftime('%W', dt) AS week, strftime('%Y', dt) AS year, min(dt) AS dt,
           CAST(hospitalizedcurrently AS float)/ population * 1000000 AS first_hosp
    FROM daily
    WHERE state = 'CA'
    GROUP BY year, week
),
Hosp2 AS (
    SELECT strftime('%W', dt) AS week, strftime('%Y', dt) AS year, min(dt) AS dt,
           CAST(hospitalizedcurrently AS float)/ population * 1000000 AS second_hosp
    FROM daily
    WHERE state = 'FL'
    GROUP BY year, week
)
SELECT Hosp1.dt AS "Date", Hosp1.first_hosp AS "California Hospitalized", Hosp2.second_hosp AS "Florida Hospitalized"
FROM Hosp1
JOIN Hosp2 ON Hosp1.dt = Hosp2.dt
ORDER BY Hosp1.dt;
```

#### Exploratory Tools

Initial explorations and data validations were performed using Spatialite_gui and QGIS. These tools helped in visually confirming geographic and temporal data alignments before deeper SQL-based analysis.

#### Transition to PostgreSQL

An attempt was made to transition approximately 30% of the project to PostgreSQL to leverage advanced functionalities like PostGIS. Although not fully implemented, this effort highlighted the potential for scaling up the analysis with more sophisticated geographic data handling capabilities but these efforts are temporarily on the back burner.

#### HTML Documents

**Interactive Documentation:** The project is documented in two HTML files, `day01.html` and `day02.html`, each structured like a Jupyter notebook. These documents feature about 30 cells per day, including:

- **Markdown Cells**: These cells provide detailed explanations, outline the objectives for each step, and contextualize the code and results. They also include reflections and insights, enhancing the readability and educational value of the documentation.
- **Code Cells**: These include the SQL queries and any other scripts used to perform the analysis. Viewing the code alongside the explanations allows for a deeper understanding of the methods and techniques applied.
- **Visualization Cells**: Contain tables and charts generated from the analysis results, providing visual evidence of the findings and making complex data more accessible and understandable.

**Comprehensive Coverage**: The documentation covers the entire analytical process from data cleaning to advanced analysis, offering a thorough walkthrough of each day's work. This approach not only showcases technical skills but also demonstrates a commitment to transparency and thorough documentation in data science projects.

## Results and Visualizations

#### Findings

The analysis primarily focused on comparing hospitalization rates due to COVID-19 between states with and without mask mandates over the period from March 2020 to March 2021. Key findings include:

- No significant statistical difference in hospitalization rates between states with mask mandates and those without, as evidenced by t-test results. This suggests that while mask mandates might have influenced public health outcomes, other factors could also play substantial roles.
- States like California and Florida showed similar trends despite differing mask mandate policies, indicating a complex interaction of multiple variables affecting hospitalization rates.

#### Visualizations

Data visualization played a crucial role in interpreting the complex relationships within the data. Using Excel, line charts were created to depict hospitalization rates per million people, segmented by week:

- **Line Charts**: Each state’s weekly hospitalization rates were plotted to visually compare trends over time. These charts were instrumental in highlighting similarities and differences in trends across states, facilitating a straightforward comparison of epidemiological impacts.

<img src="res/2024-06-29-15-52-40.png" width="700" height="400">

<img src="res/2024-06-29-15-55-01.png" width="700" height="400">

<img src="res/2024-06-29-15-57-25.png" width="700" height="400">

- **Excel Power Query**: Enabled dynamic comparisons by allowing easy adjustments of the states included in the visual analysis, enhancing the flexibility of the data exploration process.

![](res/2024-06-29-15-46-13.png)

The visualizations provided not only a clear depiction of the data but also a powerful tool for storytelling, making the data accessible and understandable to a broader audience.

## Challenges and Learnings

#### Challenges

During the project, several challenges were faced, including:

- **Data Integration**: Combining data from multiple sources, such as The Covid Tracking Project and the New York Times mask mandate dataset, required careful alignment of different data formats and timelines.
- **SQL Complexity**: The advanced SQL queries used for the analysis, particularly the CTEs and aggregation functions, initially posed difficulties in ensuring accuracy and performance.
- **Exploratory Tools Limitations**: While tools like Spatialite_gui and QGIS were invaluable for preliminary visual checks, they presented a learning curve and had limitations in handling large datasets efficiently.

#### Learnings

From these challenges, several key learnings emerged:

- **Enhanced SQL Proficiency**: Overcoming the complexities of SQL queries improved my ability to handle large datasets and perform intricate data manipulations more effectively.
- **Data Cleaning Skills**: The necessity of aligning and cleaning data from different sources honed my data preprocessing skills, a critical aspect of any data analysis workflow.
- **Adaptability with Tools**: Learning to utilize and transition between different tools, from SQL databases to Excel and GIS software, enhanced my flexibility and problem-solving skills in data analysis.

These experiences have not only enriched my technical capabilities but also my approach to tackling data-related problems in future projects.

## Conclusion and Future Work

This project has provided valuable insights into the correlation between mask mandates and hospitalization rates during the COVID-19 pandemic, highlighting the complex interplay of public health policies and health outcomes. The findings suggest that while mask mandates might not significantly impact hospitalization rates, other factors certainly do, warranting further investigation.

### Future Directions:
- **Geographical Expansion**: Consider expanding the analysis to include more states or even international data to see if the trends hold true across different populations and health infrastructures.
- **Temporal Extension**: Extend the time frame beyond March 2021 to include data on vaccination impacts and newer variants of the virus.
- **Methodological Enhancements**: Explore the use of more sophisticated statistical techniques or machine learning models to predict trends or outcomes based on a wider set of variables.

This project serves as a foundation for further research and analysis in the field of public health data analytics, and I am eager to explore these future directions to deepen our understanding of pandemic response strategies.

## Appendix

County COVID: https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv

County data: https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html

Boundaries (state, county, urban): https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html


## Authors

- [lunden-bryan](https://github.com/lundeen-bryan)

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Feedback

If you have any feedback, please reach out to us on LinkedIn.

### Frequently Asked Questions (FAQs)

#### Q1: What was the main goal of this project?
**A1:** The main goal was to analyze the correlation between mask mandates and COVID-19 hospitalization rates across different states to understand if there was a statistical impact of public health policies on hospital rates.

#### Q2: Why did you choose SQL for this analysis?
**A2:** SQL was chosen for its robustness in handling and querying large datasets efficiently, which was crucial for managing the extensive data provided by The Covid Tracking Project and integrating it with additional data sources.

#### Q3: How did you handle data discrepancies?
**A3:** Data discrepancies were addressed through careful data cleaning and preprocessing steps, which included aligning date formats, standardizing state identifiers, and resolving missing or inconsistent data entries.

#### Q4: Can the findings of this project be generalized to other states or countries?
**A4:** While the findings provide insights into the states analyzed, caution should be exercised when generalizing to other regions without considering local differences in policy implementation, population density, and healthcare infrastructure.

#### Q5: What are the potential improvements for future iterations of this project?
**A5:** Future improvements could include incorporating more granular data, such as county-level analysis, extending the time frame to include more recent data, and employing advanced analytical techniques like machine learning for predictive modeling.

#### Q6: How can others contribute to or expand upon this project?
**A6:** Contributors are welcome to extend the dataset, enhance the analytical methods, or apply the framework to other public health issues. Suggestions and collaborations can be discussed via [GitHub issues or pull requests on the project repository].

## Acknowledgements

- [Awesome Readme Templates](https://awesomeopensource.com/project/elangosundar/awesome-README-templates)
- [Awesome README](https://github.com/matiassingers/awesome-readme)
- [How to write a Good readme](https://bulldogjob.com/news/449-how-to-write-a-good-readme-for-your-github-project)

Original project made for Salisbury University and Udemy by
- [Arthur Lembo - Analyze COVID-19 Data with SQL and SQLite](https://www.udemy.com/course/analyze_covid19/)