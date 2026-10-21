In this project, we build an end-to-end model.

## The Business Problem

## The Data

The data

| Attribute Name | Data Type        | Description                                                                 |
|----------------|------------------|-----------------------------------------------------------------------------|
| **InvoiceNo**  | Nominal / Object | A 6-digit unique identifier for each invoice. Numbers starting with **'C'** denote a cancelled transaction. |
| **StockCode**  | Nominal / Object | A distinct code assigned uniquely to each physical product or service fee.  |
| **Description**| Nominal / Object | The product item name or operational text descriptor.                       |
| **Quantity**   | Numeric / Integer| The number of units per transaction line. Negative values signify returns or system reversals. |
| **InvoiceDate**| Datetime / Object| The precise day and time when the transaction log was generated.            |
| **UnitPrice**  | Numeric / Float  | The unit cost of the product or fee denominated in British Pounds Sterling (£). |
| **CustomerID** | Nominal / Numeric| A unique identifier assigned to registered clients. Missing values denote unregistered guest checkouts. |
| **Country**    | Nominal / Object | The country where the purchasing customer resides.                          |


The data consists of two separate sheets, first, from `2009-12-01 to 2010-12-09`, second from `2010-12-01 to 2011-12-09`. These consists of over 1 million entries. Of course there is an overlap in the data, which we cleaned, and did some exploratory data analysis. About $20\\%$ of the data in the `customerid` are missing, and about $90\\%$ of the customers are from the UK (others are from France, Germany, Nigeria, e.t.c).
## The Analysis and Findings

## Recommendations

## Limitations
