# Library API

## Overview  
**Library API** is a backend system built with **Rails 8** that provides a complete library management workflow.  
The project was designed as a **JSON API** backend, intended to be consumed by a frontend application (e.g., React).  

The system supports:  
- User authentication and authorization with **JWT tokens**.  
- Role-based access control with fine-grained **permissions**.  
- Borrowing workflows with **due dates, renewals, and returns**.  
- Extensible design for handling multiple categories of borrowable items (not just books).  

---

## Architecture Decisions  

### 1. Authentication & Authorization  
- **JWT (JSON Web Token)** is used for stateless authentication, enabling the API to scale horizontally without session storage.  
- **Roles and Permissions**:  
  - Roles (e.g., *Librarian*, *Member*) are stored in the `roles` table.  
  - Each role has associated permissions via a `role_permissions` join table.  
  - Users are connected to roles through `user_roles`.  
  - This design allows **RBAC (Role-Based Access Control)** with flexibility to add new roles or adjust privileges without changing core logic.  

### 2. Data Model Design  
- **Borrowables**:  
  - Implemented using **Single Table Inheritance (STI)** with the `borrowables` table.  
  - This allows books, journals, or other item types to share a common interface while supporting category-specific behavior.  
  - Example: `Book < Borrowable`.  
- **Copies**:  
  - Each borrowable item can have multiple `copies`, enabling tracking of availability, condition, and status.  
- **Borrowings**:  
  - Records when a copy is borrowed, due, returned, or renewed.  
  - Supports renewal count and constraints defined at the `item_type` level (e.g., loan duration, max renewals).  
- **Item Types**:  
  - Encapsulate borrowing rules (loan period, renewals) for categories of items.  

This separation of concerns makes the schema **normalized, scalable, and extensible**.  

### 3. Service Objects & SOLID Principles  
- **Service objects** are used for complex business logic (e.g., borrowing, returning, renewing).  
- This keeps controllers thin and models focused on persistence.  
- The codebase respects **SOLID principles**:  
  - **Single Responsibility**: Controllers handle requests; services encapsulate domain logic.  
  - **Open/Closed**: Borrowables can be extended to support new item categories without modifying existing ones.  
  - **Dependency Inversion**: Business logic is decoupled from persistence.  

### 4. Serialization  
- API responses use **ActiveModel::Serializers**, ensuring consistent JSON structure and separation between internal models and exposed data.  
- This design decision avoids tight coupling between database schema and API responses.  

---

## Technical Stack  

- **Framework**: Ruby on Rails 8.0  
- **Database**: PostgreSQL  
- **Authentication**: JWT + bcrypt  
- **Pagination**: will_paginate  
- **Serialization**: ActiveModel::Serializers  
- **Testing**: RSpec + FactoryBot + Faker  
- **CORS**: rack-cors  
- **Code Quality & Security**: Rubocop Omakase + Brakeman  

---

## Entity-Relationship Diagram (ERD)  

```text
+-------------+        +-----------+        +----------+
|   Users     |        |  Roles    |        |Permissions|
+-------------+        +-----------+        +----------+
| id          |        | id        |        | id        |
| email       |        | name      |        | name      |
| name        |        | desc      |        | resource  |
| last_name   |        +-----------+        | action    |
| birth_date  |             ^               +----------+
+-------------+             |                     ^
       ^                     \                    |
       |                      \                   |
       |                       v                  /
+---------------+       +---------------+   +---------------+
|  User_Roles   |       |Role_Permissions|   |   Borrowings  |
+---------------+       +---------------+   +---------------+
| user_id       |------>| role_id       |   | id            |
| role_id       |       | permission_id |   | user_id       |
+---------------+       +---------------+   | copy_id       |
                                            | borrowed_at   |
                                            | due_at        |
                                            | returned_at   |
                                            +---------------+
                                                   ^
                                                   |
                                            +---------------+
                                            |    Copies     |
                                            +---------------+
                                            | id            |
                                            | borrowable_id |
                                            | status        |
                                            +---------------+
                                                   ^
                                                   |
                                            +---------------+
                                            |  Borrowables  |
                                            +---------------+
                                            | id            |
                                            | title         |
                                            | item_type_id  |
                                            | type          |
                                            +---------------+
                                                   ^
                                                   |
                                            +---------------+
                                            |  Item_Types   |
                                            +---------------+
                                            | id            |
                                            | name          |
                                            | loan_duration |
                                            | max_renewals  |
                                            +---------------+
```

---

## Testing Strategy  

The project uses **RSpec** for unit, request, and integration testing:  
- **Authentication**: Ensures secure token generation and expiration.  
- **Authorization**: Tests that permissions are enforced for librarians vs. members.  
- **Borrowing flow**: Covers borrowing, returning, and renewing copies.  
- **Data validation**: Ensures integrity of users, roles, and borrowable items.  

Factories with **FactoryBot** and **Faker** simplify test setup and data generation.  

---

## Setup Instructions  

1. **Clone repository**  
   ```bash
   git clone https://github.com/RobertoRuedaQ/library_api.git
   cd library_api
   ```  

2. **Install dependencies**  
   ```bash
   bundle install
   ```  

3. **Setup database**  
   ```bash
   bin/rails db:create db:migrate db:seed
   ```  

4. **Run tests**  
   ```bash
   bundle exec rspec
   ```  

5. **Start server**  
   ```bash
   bin/rails server
   ```  

---

## Future Improvements  
- Add audit logs for borrowing actions.  
- Extend borrowables to include journals, digital media, etc.  
- Implement background jobs (Solid Queue) for overdue notifications.  
- Provide GraphQL API as an alternative to REST.  