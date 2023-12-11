CREATE USER 'user_w'@'%' IDENTIFIED BY 'password1234';
GRANT ALL ON user.* TO 'user_w'@'%';

CREATE USER 'user_r'@'%' IDENTIFIED BY 'password1234';
GRANT SELECT ON user.* TO 'user_r'@'%';
