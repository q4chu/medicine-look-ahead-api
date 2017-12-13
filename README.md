# README #

This README would normally document whatever steps are necessary to get your application up and running.

# Purpose #
Search
(1) Drug Information Number (DIN) or Natural Product Number (NPN)<br />
(2) Predictive entry by drug ‘Non-proprietary Therapeutic Product’ (NTP) name (e.g. aml- would offer list of amlodipine drugs) (from CCDDS). The NTP formal name should appear in the predictive entry pick list.<br />

Prioritization
Ordering should be alphabetical. Products that that are in the BC drug formulary should be in bolded text (or highlighted in some way). <br />
The downloadable formulary lists the DINs of all of included products, so these DINs just need to be mapped to the NTPs using the MP-NP-TM Relationship document above.(actually need link three csv files, <br />
npt-full-release join mp-np-tm relationship join mp_to_din_or_npn_mapping to associate ntp name with DIN and ntp formal name)

# LookUp #
(1)searchByDin:<br />
search all the drugs with the Din number<br />
(2)searchByGuess:<br />
predict drugs that have similar categories with the provided category and prioritize and bold drugs in BC drug formulary<br />
NOTE: since alomost all drugs are in the formulary, most of drugs will be bold<br />
Query to check the result(19 rows):<br />
select distinct health_canada_identifier,mp_formal_name,DIN_PIN as in_formulary from ccdds left join BC_drug_formulary form on ccdds.health_canada_identifier = form.DIN_PIN where DIN_PIN is null;<br />
(3)searchByCategory + selectCategory<br />
predict drugs' categories, after the client select the category, show list of drugs and bold and prioritize drugs in BC drug formulary

# database #
ccdds and bc drug formulary<br />
ccdds contain all the drugs and categories<br />
bc drug formulary is the drug in the formulary plan

LNHPD is not used since it does not have header lines. 