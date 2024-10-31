# Dynamic Pricing Engine

This is a robust eCommerce API designed to facilitate dynamic pricing strategies. By leveraging real-time data from market trends and competitor behavior, the API allows users to create and implement flexible pricing rules.

With this API, businesses can adjust their prices dynamically based on various factors, ensuring they remain competitive and maximize revenue. The system is equipped to analyze trends in customer behavior and competitor pricing, enabling the creation of tailored pricing strategies that respond to changing market conditions.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Internal Components](#internal-components)
- [Possible Issues](#possible-issues)
- [Further Improvements](#further-improvements)
- [API Reference](#api-reference)

## Features

- **Feature 1**: Import products via CSV in batches.
- **Feature 2**: Adding products to a cart and processing cart items into an order.
- **Feature 3**: Create price adjustment rules based on trends or competitor prices, with flexible time frames: daily, weekly, monthly, or yearly.
- **Feature 4**: Capture prices when users add items to their cart to honor the price at the moment of selection, ensuring they receive the accurate pricing they expect at checkout.
- **Feature 5**: Store trends and price adjustment histories to enable comprehensive analytics. This allows for the assessment of pricing strategies, performance tracking, and informed decision-making based on historical data insights.

## Installation

To install this application, follow these steps:

1. **Ruby on Rails setup**
  You can follow the guide from [GoRails](https://gorails.com/setup/ubuntu/24.04) to install Rails for linux or MacOs.

2. **Installing docker**
  You may download [docker desktop](https://docs.docker.com/desktop/) for monitoring the images or just plainly install docker on your PC [docker installation commands](https://docs.docker.com/engine/install/)

## Usage

To use this application, follow these steps:

1. **ENV setup**
  You need create a `.env` file with the API keys:

  ```plaintext
  COMPETITOR_API_BASE_URI=https://sinatra-pricing-api.fly.dev
  COMPETITOR_API_KEY=demo123
  ```

1. **Run bundle install**
  You need install all the required gems:

  ```bash
  bundle install
  ```

1. **Run MongoDb and Redis via Docker**
  You need to run the command below or use your docker desktop:

  ```bash
  docker compose up
  ```

1. **Run rails server and sidekiq**
  You need to run the command below or use your docker desktop:

  ```bash
  rails s
  
  # Separate terminal
  sidekiq
  ```

### Mongo will run on replica set state for Transactions

  If you encounter any issues with MongoDB connection, please add the network IP address of the container to your etc/hosts

  ```plaintext
  172.18.0.2      mongodb
  ```

## Internal Components

1. **Product import via CSV**
  This implementation handles product CSV imports in batches using a file streaming approach, which conserves memory by avoiding the loading of the entire file at once—especially beneficial for large files. I’ve implemented a manual batching method currently set to 10, given that the sample CSV contains only 50 products. Adjusting this to 100 would further reduce overhead compared to inserting records individually. This approach is designed to efficiently manage large product imports. Additionally, I've added a product import status tracker, though I recently discovered that there’s an existing Sidekiq extension for this functionality.

2. **Trends tracker**
  This implementation manages trend data for marketing, analytics, and a dynamic pricing engine. It tracks cart additions and orders placed for each product. In the future, I plan to add API endpoints to filter and aggregate this data by timeframes (daily, weekly, monthly, yearly).

3. **Price adjustment rules**
  This implementation manages the creation of price adjustment rules for various products. I designed this feature to allow distinct rules for each product, as factors such as trend analysis, inventory levels, competitor prices, and product research can vary significantly. This flexibility is essential for an effective dynamic pricing engine. Additionally, users can set rules based on timeframes, allowing for adjustments to be applied daily, weekly, monthly, or yearly.

4. **Price Based on Effective Date**
  This implementation allows users to utilize specific prices based on their effective date. It prioritizes honoring the price that users initially saw, ensuring integrity and trust. This feature is similar to functionality found in platforms like Agoda, particularly for a dynamic pricing engine operating in real time.

5. **Competitor Price Fetching via Price adjustment rule**
  This implementation enables users to create rules for competitor pricing, with scheduling options for daily, weekly, monthly, or yearly execution. Users can choose between two strategies: match and undercut. This feature fetches competitor prices to maintain competitive positioning in the market.

## Possible issues

- **Handling large datasets**: Implementing pagination will resolve issues related to slow API response times when handling large datasets, improving overall performance and user experience.
- **Concurrency Problems**: Introducing database locking will mitigate concurrency issues during dynamic price adjustments, preventing race conditions that could lead to data inconsistency.
- **Cart Total Calculations**: Optimizing the cart total price calculation will address performance issues associated with slow calculations and ensure greater accuracy, enhancing user trust.
- **Delayed Price Adjustments**: Scheduling price adjustment rules for trends and inventory updates will eliminate the need for constant checks on price adjustment rules whenever a product is added to the cart, an order is placed, or inventory changes occur.
- **Product's price adjustments**: There is a need to aggregate historical data, as it is currently embedded within the Product document, which has a 16 MB size limit.

## Further Improvements

- **Implement Pagination in API**: Adding pagination across various API endpoints will enhance performance and improve user experience by allowing clients to retrieve data in manageable chunks.
- **Introduce Database Locking for Dynamic Price Adjustments**: Implementing locking mechanisms will help mitigate concurrency issues during dynamic price adjustments, ensuring data integrity and preventing race conditions.
- **Optimize Cart Total Price Calculation**: Enhance the calculation of the cart's total price using Mongoid aggregation for improved performance and accuracy.
- **Schedule Price Adjustment Rules for Trends and Inventory Updates**: Apply price updates through scheduled background jobs (daily, weekly, etc.) to ensure timely adjustments based on trends and inventory changes.
- **Implement Background Jobs for Price Adjustment Aggregation**: Create background jobs to periodically aggregate historical price adjustment data. This will help manage data size limits within the Product document, allowing for efficient storage and retrieval of pricing history without impacting the performance of real-time operations.

## API Reference

  Here's my link to the API documentations via [postman](https://www.postman.com/lively-spaceship-99649/public-applications/collection/g3o5lcf/dynamic-pricing-engine)
