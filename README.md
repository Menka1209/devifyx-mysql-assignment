# 📌 DevifyX MySQL Assignment — Password Reset & Email Verification System

👤 *Author:* Menka Bhardwaj  
📁 *File:* devifyx-mysql-assignment-menka.sql  
🗓 *Tech Stack:* Pure MySQL 8.0+

---

## 📝 Project Overview

This project implements a complete backend system in SQL for:

- ✅ User registration with email verification
- ✅ Password reset via token
- ✅ Secure token generation and expiry control
- ✅ Audit logging of all key actions
- ✅ Automatic cleanup of used/expired tokens

The entire logic is implemented using only SQL (no backend/frontend).

---

## 📂 Features

| Feature                         | Description                                |
|----------------------------------|--------------------------------------------|
| users table                    | Stores user email, hashed password         |
| email_verification            | Stores email verification tokens           |
| password_reset                | Manages password reset requests            |
| audit_trail                   | Logs all actions for transparency          |
| generate_token()              | Generates random, secure tokens            |
| initiate_email_verification() | Issues new token for email verification    |
| verify_email()                | Verifies user based on token               |
| initiate_password_reset()     | Starts password reset process              |
| reset_password()              | Resets password with token validation      |
| cleanup_expired_tokens        | Scheduled event to purge expired data      |

---

## 🧪 Testing Instructions

To test the logic:
1. Insert a sample user
2. Run CALL initiate_email_verification(...)
3. Use the token from email_verification table to run CALL verify_email(...)
4. Repeat similar flow for password reset
5. View logs in audit_trail

---

## 🧠 AI Use Disclaimer

This project was completed independently.  
ChatGPT was used only for guidance and step-by-step learning.  
All logic was written, understood, and tested by me.

---

## 📤 Submission

Please refer to the .sql file submitted as part of this assignment.
