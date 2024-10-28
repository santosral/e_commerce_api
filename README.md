# Dynamic Pricing Engine

This is a robust eCommerce API designed to facilitate dynamic pricing strategies. By leveraging real-time data from market trends and competitor behavior, the API allows users to create and implement flexible pricing rules.

With this API, businesses can adjust their prices dynamically based on various factors, ensuring they remain competitive and maximize revenue. The system is equipped to analyze trends in customer behavior and competitor pricing, enabling the creation of tailored pricing strategies that respond to changing market conditions.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)

## Features

- **Feature 1**: Create price adjustment rules based on trends or competitor prices, with flexible time frames: daily, weekly, monthly, or yearly..
- **Feature 2**: Capture prices when users add items to their cart to honor the price at the moment of selection, ensuring they receive the accurate pricing they expect at checkout.
- **Feature 3**: Store trends and price adjustment histories to enable comprehensive analytics. This allows for the assessment of pricing strategies, performance tracking, and informed decision-making based on historical data insights.

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

2. **Run bundle install**
  You need install all the required gems:

  ```bash
  bundle install
  ```

3. **Run MongoDb and Redis via Docker**
  You need to run the command below or use your docker desktop:

  ```bash
  docker compose up
  ```

### Mongo will run on replica set state for Transactions

  If you encounter any issues with MongoDB connection, please add the network IP address of the container to your etc/hosts

  ```plaintext
  172.18.0.2      mongodb
  ```

## API Reference

  Here's my link to the API documentations via [postman](https://www.postman.com/lively-spaceship-99649/public-applications/collection/g3o5lcf/dynamic-pricing-engine)
