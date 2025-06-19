/*Author:Menka 
Description :
its a sql script that implements a complete  backend system to support :
-Email Verification with token validation
-Secure Password reset process 
-Audit logging and automated token cleanup 

AI Usage note:-
		        I used CHATGPT as a learning assistant to guide me step-by-step. 
                All SQL Logic ,flow design,and structure were written and understood by me.
*/
-- step  :userstable 
create table users(
                     id int Auto_Increment  primary key ,
                     email varchar(255) unique not null,
                     password_hash varchar(255) not null ,
                     is_verified boolean default false ,
                     created_at datetime default current_timestamp 
                     );
select * from users;
-- email_verification table 
create table email_verification(
                                id int  AUTO_INCREMENT primary key,
                                user_id int not null,
                                token varchar(255) unique not null,
                                expires_at datetime  not null,
                                is_used boolean default false,
                                created_at datetime default CURRENT_TIMESTAMP ,
                                foreign key(user_id) references users(id)  on delete cascade);
				
-- Step 3: password_reset table
create table password_reset(
                            id int AUTO_INCREMENT primary key,
                            user_id int not null,
                            token varchar(255) unique not null ,
                            expires_at datetime not null,
                            is_used boolean default false,
                            created_at datetime default current_timestamp,
                            foreign key(user_id) references users(id) on delete cascade );
                            
-- Step 4: audit_trail table
create table audit_trail(
                         id int AUTO_INCREMENT primary key,
                         user_id int not null,
                         action_type varchar(50)  not null, 
                         status varchar(50)  not null,
                         created_at datetime default current_timestamp,
                         foreign key(user_id) references users(id) on delete cascade );

--Step 5: generate_toke function 
DELIMITER $$
create function generate_token()
returns varchar(255)
NOT DETERMINISTIC 
READS SQL DATA 
BEGIN 
      DECLARE TOKEN VARCHAR(255);
      SET TOKEN=REPLACE(UUID(),'-','');
      RETURN token;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS generate_token;

DELIMITER $$

-- drop procedure if exists 
DROP PROCEDURE IF EXISTS initiate_email_verification$$
-- Step 6:  initiate_email_verification procedure
CREATE PROCEDURE initiate_email_verification(IN userEmail VARCHAR(255))
BEGIN
    DECLARE userId INT;
    DECLARE token VARCHAR(255);
    DECLARE expiry DATETIME;

    SELECT id INTO userId FROM users WHERE email = userEmail;

    SET token = generate_token();
    SET expiry = NOW() + INTERVAL 30 MINUTE;

   
    INSERT INTO email_verification (user_id, token, expires_at)
    VALUES (userId, token, expiry);
    UPDATE users SET is_verified = FALSE WHERE id = userId;
INSERT INTO audit_trail (user_id, action_type, status)
    VALUES (userId, 'email_verification', 'initiated');
END$$

DELIMITER ;

-- Step7 : verify email procedure 
DELIMITER $$
CREATE PROCEDURE verify_email(IN 
tokenInput varchar(255))
BEGIN 
      DECLARE userid int;
      
      select user_id into userid 
      from email_verification 
      where token=tokenInput
      and is_used = false 
      and expires_at>now();
      
	if userid is not null then 
      update email_verification 
      set is_used=true
      where token=tokeninput;
       
       update users
       set is_verified=true
      where id=userid;
      
      insert into audit_trail
      (user_id,action_type,status)
      values( userid,'email_verification','used');
      
      select 'email verification successful.' as message;
	else 
      select 'invalid or expired token.' as message; 
	end if;
END $$ 
DELIMITER ;
      
DELIMITER $$
CREATE PROCEDURE initiate_password_reset(IN useremail varchar(255))
BEGIN
      DECLARE userid int;
      DECLARE token varchar(255);
      DECLARE expiry datetime;
      select id into userid from users
	where email=useremail;
     IF userid is not null then
     set token=generate_token();
     set expiry=now() + interval 30 minute;
     insert into password_reset(user_id,token,expiry_at) values(userid,token,expiry);
     insert into audit_trail(user_id,action_type,status)values(userid,'password_reset','initiated');
     select token as reset_token;
	else
    select 'User not found.' as message;
    end if;
END$$
DELIMITER ;

-- Step 8: initiate password reset procedure 
DELIMITER $$
CREATE PROCEDURE reset_password(IN tokenInput VARCHAR(255), IN newPassword VARCHAR(255))
BEGIN
    DECLARE userId INT;
SELECT user_id INTO userId
    FROM password_reset
    WHERE token = tokenInput
      AND is_used = FALSE
      AND expires_at > NOW();

IF userId IS NOT NULL THEN
	UPDATE users
        SET password_hash = newPassword
        WHERE id = userId;
UPDATE password_reset
        SET is_used = TRUE
        WHERE token = tokenInput;
    INSERT INTO audit_trail (user_id, action_type, status)
        VALUES (userId, 'password_reset', 'used');
SELECT 'Password reset successful.' AS message;
    ELSE
        SELECT 'Invalid or expired token.' AS message;
    END IF;
END$$
DELIMITER ;

-- event schedular enabled
SET GLOBAL event_scheduler = ON;

--Step 10: cleanup expired token event 
DELIMITER $$
CREATE EVENT cleanup_expired_tokens
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    DELETE FROM email_verification
    WHERE expires_at < NOW() AND is_used = TRUE;

    DELETE FROM password_reset
    WHERE expires_at < NOW() AND is_used = TRUE;

    DELETE FROM audit_trail
    WHERE created_at < NOW() - INTERVAL 30 DAY;
END$$
DELIMITER ;

--Sample data + test queries 
INSERT INTO users(email,password_hash) values('bnidhi004@gmail.com','Menka123');
call
initiate_email_verification('bnidhi004@gmail.com');
select * from email_verification;

call verify_email('6450c3154c4311f0b99d54e1add0b93d');

call initiate_password_reset('bnidhi004@gmail.com');

select * from password_reset;
call
reset_password('6450c3154c4311f0b99d54e1add0b93d','Menka@123');

select * from users;
select * from audit_trail;
show events;