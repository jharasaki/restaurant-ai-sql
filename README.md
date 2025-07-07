# Restaurant AI SQL Project  
# SQL → Tableau → ML Mini-Case

A project that walks from raw CSVs to business insights and a tiny AI prototype.

**Data:** 12,234 order line-items, 32 menu items — Jan 1 - Mar 31 2023  
**Tools:** DuckDB (SQL), Tableau Public, Python (scikit-learn)

---

## Phase summary

| Phase | What I built | Links / files |
|-------|--------------|---------------|
| **1** | Data load & sanity checks | `analysis.sql` |
| **2** | SQL CTE join, top-seller window fn, margin calc | `analysis.sql`, `outputs/order_items.csv` |
| **3** | Public Tableau dashboard & 5-slide PDF | [Live dashboard](<https://public.tableau.com/views/restaurant_ai_sqlproject/RestaurantInsights?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link>), `outputs/dashboard.png`, `outputs/restaurant_insights_summary.pdf` |
| **4** | Logistic model to flag >\$100 orders | `outputs/high_spend_clf.joblib`, `outputs/model_metrics.json` |

---

## Quick start

```bash
git clone https://github.com/jharasaki/restaurant-ai-sql.git
cd restaurant-ai-sql
pip install -r requirements.txt
jupyter notebook restaurant_project.ipynb   # or open in Colab
