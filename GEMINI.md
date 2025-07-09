Project: Sparta Node Test App
General Instructions
This is a Node.js application intended for use with Jenkins. The main application code is in the app directory.

The application uses Node.js v20.

The main application file is app/app.js.

To start the server, run npm start.

To run tests, use npm test.

Jenkins & CI/CD Context
The primary goal for this project is to maintain a robust CI/CD pipeline using Jenkins.

A Jenkinsfile should exist at the project root to define the build pipeline.

The pipeline should be triggered on every push to the remote repository.

Pipeline Stages: When modifying the Jenkinsfile, ensure it includes stages for:

Checking out the source code.

Installing dependencies (npm install).

Running tests (npm test).

Test Failures: Be aware that tests related to the blog posts (/posts) are expected to fail if the DB_HOST environment variable is not set. This is by design.

Coding Style & Conventions
Dependencies: Avoid introducing new external dependencies unless absolutely necessary. If a new one is needed, provide a justification.

Testing:

The testing framework is Mocha and Chai.

All new features should have corresponding tests in the app/test/ directory.

Database: The application uses MongoDB and Mongoose. Database seeding is handled by app/seeds/seed.js and runs automatically after npm install.

Specific Files of Note
app/app.js: This is the main Express server file. It contains a deliberately inefficient Fibonacci function for performance testing and a commented-out, insecure route for security testing.

app/test/test-server.js: Contains the Mocha tests for the application endpoints.

package.json: Defines all project dependencies and scripts. Note the postinstall script which seeds the database.