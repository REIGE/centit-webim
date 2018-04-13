DROP VIEW IF EXISTS F_V_UNREAD_CHAT_MSG;
DROP VIEW IF EXISTS F_V_UNREAD_GROUP_MSG;
DROP VIEW IF EXISTS F_V_LAST_UNREAD_CHAT_MSG;
DROP VIEW IF EXISTS F_V_LAST_UNREAD_GROUP_MSG;

DROP TABLE IF EXISTS F_WEB_IM_GROUP;
DROP TABLE IF EXISTS F_WEB_IM_GROUP_MEMBER;
DROP TABLE IF EXISTS F_WEB_IM_GROUP_MEMBER;

CREATE TABLE F_WEB_IM_GROUP
(
    GROUP_ID             VARCHAR(32) NOT NULL,
    OS_ID                varchar(20) NOT NULL,
    GROUP_TYPE           CHAR NOT NULL COMMENT 'U  unit机构群不能删除，不能退出  G Group 普通群',
    GROUP_NAME           VARCHAR(100) NOT NULL COMMENT '群名称',
    CREATOR             VARCHAR(32) NOT NULL,
    CREATE_TIME          DATETIME COMMENT '创建时间',
    GROUP_NOTICE         VARCHAR(1000) COMMENT '群描述',
    PRIMARY KEY (GROUP_ID)
);

CREATE TABLE F_WEB_IM_GROUP_MEMBER
(
    OS_ID                varchar(20) NOT NULL,
    USER_CODE            varchar(32) NOT NULL,
    UNIT_CODE            varchar(32) NOT NULL,
    GROUP_MEMO           varchar(1000) COMMENT '用户对群的备注' ,
    GROUP_ALIAS          varchar(100) COMMENT '用户在群中的昵称' ,
    JOIN_TIME            DATETIME NOT NULL,
    LAST_PUSH_TIME       DATETIME NOT NULL COMMENT '最后阅读时间' ,
    PRIMARY KEY (USER_CODE, UNIT_CODE)
);

CREATE VIEW F_V_UNREAD_CHAT_MSG AS
select OS_ID, RECEIVER, SENDER, COUNT(*) as UNREAD_SUM, MAX(SEND_TIME) as LAST_MSG_SEND_TIME
from F_WEB_IM_MESSAGE
where MSG_TYPE = 'C' and MSG_STATE = 'U'
group by OS_ID,RECEIVER,SENDER;


CREATE VIEW F_V_UNREAD_GROUP_MSG AS
select a.OS_ID, b.USER_CODE, b.UNIT_CODE, COUNT(*) as UNREAD_SUM, MAX(SEND_TIME) as LAST_MSG_SEND_TIME
from F_WEB_IM_MESSAGE a left join F_WEB_IM_GROUP_MEMBER b on
    (a.OS_ID=b.OS_ID and a.RECEIVER = b.UNIT_CODE)
where a.MSG_TYPE = 'G' and ( a.send_time > b.LAST_PUSH_TIME or b.LAST_PUSH_TIME is null)
group by a.OS_ID, b.USER_CODE, b.UNIT_CODE;



CREATE VIEW F_V_LAST_UNREAD_CHAT_MSG AS
select a.OS_ID, a.RECEIVER, a.SENDER, a.UNREAD_SUM , b.SEND_TIME,
       b.MSG_ID, b.MSG_TYPE, b.MSG_STATE, b.CONTENT
from F_V_UNREAD_CHAT_MSG a join F_WEB_IM_MESSAGE b
   on (a.OS_ID = b.OS_ID and a.SENDER = b.SENDER
       and a.RECEIVER = b.RECEIVER and a.LAST_MSG_SEND_TIME = b.SEND_TIME);


CREATE VIEW F_V_LAST_UNREAD_GROUP_MSG AS
select a.OS_ID, a.UNIT_CODE, b.SENDER, b.RECEIVER, a.UNREAD_SUM , b.SEND_TIME,
       b.MSG_ID, b.MSG_TYPE, b.MSG_STATE, b.CONTENT
from F_V_UNREAD_GROUP_MSG a join F_WEB_IM_MESSAGE b
   on (a.OS_ID = b.OS_ID and a.UNIT_CODE = b.RECEIVER and a.LAST_MSG_SEND_TIME = b.SEND_TIME);

