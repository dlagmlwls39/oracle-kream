[ �Ǹ� ���� ]
-- ������
CREATE SEQUENCE pbid_id INCREMENT BY 1 START WITH 6;
CREATE SEQUENCE gbid_id INCREMENT BY 1 START WITH 4;
CREATE SEQUENCE mat_id INCREMENT BY 1 START WITH 2;

drop SEQUENCE gbid_id;
drop SEQUENCE mat_id;

---------------------------------------------------------------------------

< �Ǹ����� >
-- �����Ǹ� ���� 0, �Ǹſ��� 0
1. ��ü ��ȸ
CREATE OR REPLACE PROCEDURE pbid_default
(
    pemail  tb_member.m_email%type
)
IS
    viamge   tb_item.i_image%type;
    vname    tb_item.i_name_eng%type;
    vsize    tb_panmaebid.pbid_size%type;
    vprice   varchar2(20);
    vexdate  varchar2(10);  -- ������
    CURSOR c_pbid IS
                SELECT i_image, i_name_eng, pbid_size
                         , TO_CHAR(pbid_price, 'FM999,999,999,999') || '��' gbid_price
                         , TO_CHAR(pbid_rdate + pbid_deadline, 'YYYY/MM/DD') exdate
                FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id
                WHERE pbid_keepcheck = 0 and pbid_complete = 0 and m_email = pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE;  
                    -- �Ⱓ �⺻��: �ֱ� 2����
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- �Ǹ� ���� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ �Ǹ� ���� ]');
    DBMS_OUTPUT.PUT_LINE('�Ⱓ: ' || ADD_MONTHS(SYSDATE, -2) || ' ~ ' || SYSDATE || ' (�ֱ� 2����)');
    OPEN c_pbid;
    LOOP
        FETCH c_pbid INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN c_pbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('�Ǹ������: ' || vprice || ', ������: ' || vexdate);
    END LOOP;
    IF c_pbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�Ǹ� ���� ������ �����ϴ�.');
    END IF;
    CLOSE c_pbid;
END;
-- Procedure PBID_DEFAULT��(��) �����ϵǾ����ϴ�.
EXEC pbid_default('lklk9803@gmail.com');


2. �Ⱓ�� ��ȸ
CREATE OR REPLACE PROCEDURE pbid_date
(
    pemail    tb_member.m_email%type
    , psdate  varchar2  -- �Է� ������
    , pedate  varchar2  -- �Է� ������
)
IS  
    viamge   tb_item.i_image%type;
    vname    tb_item.i_name_eng%type;
    vsize    tb_panmaebid.pbid_size%type;
    vprice   varchar2(20);
    vexdate  varchar2(10);  -- ������
    CURSOR c_pbid IS
                SELECT i_image, i_name_eng, pbid_size
                         , TO_CHAR(pbid_price, 'FM999,999,999,999') || '��' pbid_price
                         , TO_CHAR(pbid_rdate + pbid_deadline, 'YYYY/MM/DD') exdate
                FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id
                WHERE pbid_keepcheck = 0 and pbid_complete = 0 and m_email = pemail
                    and pbid_rdate BETWEEN TO_DATE(psdate, 'YYYY-MM-DD') AND TO_DATE(pedate, 'YYYY-MM-DD'); 
BEGIN
    DBMS_OUTPUT.PUT_LINE('[ �Ⱓ�� ��ȸ ]');
    DBMS_OUTPUT.PUT_LINE('�Ⱓ: ' || psdate || ' ~ ' || pedate);
    
    OPEN c_pbid;
    LOOP
        FETCH c_pbid INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN c_pbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('�Ǹ������: ' || vprice || ', ������: ' || vexdate);
    END LOOP;
    IF c_pbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�Ǹ� ���� ������ �����ϴ�.');
    END IF;
    CLOSE c_pbid;
END;
-- Procedure PBID_DATE��(��) �����ϵǾ����ϴ�.
EXEC pbid_date('lklk9803@gmail.com', '2022-05-23', '2022-06-28');
EXEC pbid_date('lklk9803@gmail.com', '2022-10-23', '2023-01-16');
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'lklk9803@gmail.com', 1, null, 240, 155000
            , TO_DATE('2023/01/10', 'YYYY/MM/DD'), 30, 0, 0, '����6', 0, '������', 1550, null, null);
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'lklk9803@gmail.com', 1, null, 240, 170000
            , TO_DATE('2022/12/15', 'YYYY/MM/DD'), 30, 0, 0, '����6', 0, '������', 1700, null, null);
          
SELECT * FROM tb_panmaebid;


3. �Ǹ�������� ����
CREATE OR REPLACE PROCEDURE pbid_price_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0�̸� ��������, 1�̸� ��������
)
IS
    vsql    varchar2(1000);
    viamge  tb_item.i_image%type;
    vname   tb_item.i_name_eng%type;
    vsize   tb_panmaebid.pbid_size%type;
    vprice  number(12);
    vexdate date;  -- ������
    vcur    SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, pbid_size, pbid_price, pbid_rdate + pbid_deadline ';
    vsql := vsql || ' FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id ';
    vsql := vsql || ' WHERE pbid_keepcheck = 0 and pbid_complete = 0 and m_email = :pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ �Ǹ������ �������� ���� ]');
        vsql := vsql || ' ORDER BY pbid_price ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ �Ǹ������ �������� ���� ]');
        vsql := vsql || ' ORDER BY pbid_price DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('�Ǹ������: ' || TO_CHAR(vprice, 'FM999,999,999,999')
                            || '��, ������: ' || TO_CHAR(vexdate, 'YYYY/MM/DD'));
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�Ǹ� ���� ������ �����ϴ�.');
    END IF;
    CLOSE vcur;
END;
-- Procedure PBID_PRICE_ORDER��(��) �����ϵǾ����ϴ�.
EXEC pbid_price_order('lklk9803@gmail.com', 0);
EXEC pbid_price_order('lklk9803@gmail.com', 1);


4. �����ϼ� ����
CREATE OR REPLACE PROCEDURE pbid_exdate_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0�̸� ��������, 1�̸� ��������
)
IS
    vsql    varchar2(1000);
    viamge  tb_item.i_image%type;
    vname   tb_item.i_name_eng%type;
    vsize   tb_panmaebid.pbid_size%type;
    vprice  number(12);
    vexdate date;  -- ������
    vcur    SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, pbid_size, pbid_price, pbid_rdate + pbid_deadline AS exdate ';
    vsql := vsql || ' FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id ';
    vsql := vsql || ' WHERE pbid_keepcheck = 0 and pbid_complete = 0 and m_email = :pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ ������ �������� ���� ]');
        vsql := vsql || ' ORDER BY exdate ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ ������ �������� ���� ]');
        vsql := vsql || ' ORDER BY exdate DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('�Ǹ������: ' || TO_CHAR(vprice, 'FM999,999,999,999')
                            || '��, ������: ' || TO_CHAR(vexdate, 'YYYY/MM/DD'));
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�Ǹ� ���� ������ �����ϴ�.');
    END IF;
    CLOSE vcur;
END;
-- Procedure PBID_EXDATE_ORDER��(��) �����ϵǾ����ϴ�.
EXEC pbid_exdate_order('lklk9803@gmail.com', 0);
EXEC pbid_exdate_order('lklk9803@gmail.com', 1);
-- �׽�Ʈ ������ ����
DELETE FROM tb_panmaebid WHERE pbid_id >= 6;


5. ������ ��ǰ ������
-- ��ǰ ����, ���� ������ ���� ������ ����
-- ���Ƽ ���� ������ ���� ������ ī�� ������ ����
-- �ݼ� �ּҴ� ���� ������ ��� �ּҿ� ����
5-1. �Ǹ� ���� ����
CREATE OR REPLACE PROCEDURE pbid_account
(
    pemail  tb_account.m_email%type
)
IS
    vbank   tb_account.ac_bank%type;
    vnum    tb_account.ac_num%type;
BEGIN
    SELECT ac_bank, ac_num INTO vbank, vnum
    FROM tb_account
    WHERE m_email = pemail;
    
    DBMS_OUTPUT.PUT_LINE('[ �Ǹ� ���� ���� ]');
    DBMS_OUTPUT.PUT_LINE(vbank || RPAD(' ', LENGTH(vnum), '*'));
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('[ �Ǹ� ���� ���� ]');
        DBMS_OUTPUT.PUT_LINE('�Ǹ� ���� ���°� �����ϴ�.');
END;
-- Procedure PBID_ACCOUNT��(��) �����ϵǾ����ϴ�.
EXEC pbid_account('lklk9803@gmail.com');
EXEC pbid_account('as@naver.com');  -- ���� �߻�
select * from tb_account;


< ���� �� >
-- �����Ǹ� ���� 0, �Ǹſ��� 1
1. ���º� ��ȸ
CREATE OR REPLACE PROCEDURE ping_state
(
    pemail       tb_member.m_email%type
    , pitemstate tb_panmaebid.pbid_itemstate%type
)
IS
    viamge  tb_item.i_image%type;
    vname   tb_item.i_name_eng%type;
    vsize   tb_panmaebid.pbid_size%type;
    vstate  tb_panmaebid.pbid_itemstate%type;
    CURSOR c_pbid IS
                SELECT i_image, i_name_eng, pbid_size, pbid_itemstate
                FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id
                WHERE pbid_keepcheck = 0 and pbid_complete = 1 and m_email = pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE
                    and pbid_itemstate = pitemstate;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- �Ǹ� ���� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ ���� �� ]');
    DBMS_OUTPUT.PUT_LINE('[ ���º� ��ȸ ]');
    DBMS_OUTPUT.PUT_LINE('������ ����: ' || pitemstate);
    OPEN c_pbid;
    LOOP
        FETCH c_pbid INTO viamge, vname, vsize, vstate;
        EXIT WHEN c_pbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('����: ' || vstate);
    END LOOP;
    IF c_pbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�ŷ� ������ �����ϴ�.');
    END IF;
    CLOSE c_pbid;
END;
-- Procedure PING_STATE��(��) �����ϵǾ����ϴ�.
EXEC ping_state('sdjsd@naver.com', '�߼ۿ�û');


2. ���¼� ����
CREATE OR REPLACE PROCEDURE ping_state_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0�̸� ��������, 1�̸� ��������
)
IS
    vsql    varchar2(1000);
    viamge  tb_item.i_image%type;
    vname   tb_item.i_name_eng%type;
    vsize   tb_panmaebid.pbid_size%type;
    vstate  tb_panmaebid.pbid_itemstate%type;
    vcur    SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, pbid_size, pbid_itemstate ';
    vsql := vsql || ' FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id ';
    vsql := vsql || ' WHERE pbid_keepcheck = 0 and pbid_complete = 1 and m_email = :pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ ���� �������� ���� ]');
        vsql := vsql || ' ORDER BY pbid_itemstate ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ ���� �������� ���� ]');
        vsql := vsql || ' ORDER BY pbid_itemstate DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vstate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('����: ' || vstate);
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�ŷ� ������ �����ϴ�.');
    END IF;
    CLOSE vcur;
END;
-- Procedure PING_STATE_ORDER��(��) �����ϵǾ����ϴ�.
EXEC ping_state_order('sdjsd@naver.com', 0);
EXEC ping_state_order('sdjsd@naver.com', 1);
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'sdjsd@naver.com', 1, null, 240, 150000
            , TO_DATE('2022/12/20', 'YYYY/MM/DD'), 30, 0, 0, '����6', 1, '�߼ۿ�û', 1500, null, null);
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'sdjsd@naver.com', 1, null, 250, 160000
            , TO_DATE('2023/01/05', 'YYYY/MM/DD'), 30, 0, 0, '����6', 1, '�԰�Ϸ�', 1600, null, null);


ROLLBACK;


3. ������ ��ǰ ������
-- �߼� ���� �̿ܿ� ��� ���� ����
3-1. �߼� ���� ���
CREATE OR REPLACE PROCEDURE ping_shipping
(
    pemail      tb_account.m_email%type
    , ppbid_id  tb_panmaebid.pbid_id%type
)
IS
    vcourier     tb_panmaebid.pbid_courier%type;
    vtrackingnum tb_panmaebid.pbid_trackingnum%type;
BEGIN
    SELECT pbid_courier, pbid_trackingnum INTO vcourier, vtrackingnum
    FROM tb_panmaebid
    WHERE m_email = pemail;
    DBMS_OUTPUT.PUT_LINE('[ �߼� ���� ]');
    DBMS_OUTPUT.PUT_LINE(vcourier || ' ' || vtrackingnum);
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('�߼� ������ �����ϴ�.');
END;
-- Procedure PING_SHIPPING��(��) �����ϵǾ����ϴ�.
EXEC ping_shipping('hyungjs1234@naver.com', 2);


3-2. �߼� ���� ����
EXEC upd_shipping(2, '��ü���ù�', '736132678451');

SELECT pbid_id, pbid_courier, pbid_trackingnum 
FROM tb_panmaebid
WHERE pbid_id = 2;

ROLLBACK;


< ���� >
-- �����Ǹ� ���� 0, �Ǹſ��� 2
1. �����ϼ� ����
CREATE OR REPLACE PROCEDURE pend_caldate_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0�̸� ��������, 1�̸� ��������
)
IS
    vsql        varchar2(1000);
    viamge      tb_item.i_image%type;
    vname       tb_item.i_name_eng%type;
    vsize       tb_panmaebid.pbid_size%type;
    vcaldate    tb_matching.mat_caldate%type;
    vstate      tb_panmaebid.pbid_itemstate%type;
    vcur        SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, pbid_size, mat_caldate, pbid_itemstate ';
    vsql := vsql || ' FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id
                                     JOIN tb_matching m ON p.pbid_id = m.pbid_id ';
    vsql := vsql || ' WHERE pbid_keepcheck = 0 and pbid_complete = 2 and m_email = :pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    DBMS_OUTPUT.PUT_LINE('--- �Ǹ� ���� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ ���� ]');
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ ������ �������� ���� ]');
        vsql := vsql || ' ORDER BY mat_caldate ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ ������ �������� ���� ]');
        vsql := vsql || ' ORDER BY mat_caldate DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vcaldate, vstate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('������: ' || vcaldate || ', ����: ' || vstate);
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�ŷ� ������ �����ϴ�.');
    END IF;
    CLOSE vcur;
END;
-- Procedure PEND_CALDATE_ORDER��(��) �����ϵǾ����ϴ�.
EXEC pend_caldate_order('jeifh@gmail.com', 0);
EXEC pend_caldate_order('jeifh@gmail.com', 1);

-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/12/25', 'YYYY/MM/DD'), 30, 0, 0, '����6', 2, '����Ϸ�', 1550, '�����ù�', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 155000
            , TO_DATE('2022/12/17', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 2, '��ۿϷ�', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 18, 10, 0, 240, 155000, TO_DATE('2022/12/25', 'YYYY/MM/DD'), TO_DATE('2022/12/27', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 270, 160000
            , TO_DATE('2022/12/18', 'YYYY/MM/DD'), 30, 0, 0, '����6', 2, '����Ϸ�', 1600, '��ü���ù�', '7543135431');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 270, 160000
            , TO_DATE('2022/12/20', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 2, '��ۿϷ�', 4800, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 19, 11, 0, 270, 160000, TO_DATE('2022/12/20', 'YYYY/MM/DD'), TO_DATE('2022/12/22', 'YYYY/MM/DD'));

SELECT * FROM tb_panmaebid;
SELECT * FROM tb_gumaebid;
SELECT * FROM tb_matching;
rollback;

2. ���� ��ǰ ������
-- ������ �̿ܿ� ��� ���� ����
2-1. ������ ���
CREATE OR REPLACE PROCEDURE pend_caldate
(
    pmat_id   tb_matching.mat_id%type  -- �ֹ���ȣ
)
IS
    vcaldate  tb_matching.mat_caldate%type;
BEGIN
    SELECT mat_caldate INTO vcaldate
    FROM tb_panmaebid p JOIN tb_matching m ON p.pbid_id = m.pbid_id
    WHERE pbid_keepcheck = 0 and pbid_complete = 2 and mat_id = pmat_id;
    DBMS_OUTPUT.PUT_LINE('������: ' || TO_CHAR(vcaldate, 'YY/MM/DD'));
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('�Ǹ� ���� ��ǰ ������ �����ϴ�.');
END;
-- Procedure PEND_CALDATE��(��) �����ϵǾ����ϴ�.
EXEC pend_caldate(8);

-- �׽�Ʈ ������ ����
DELETE FROM tb_panmaebid WHERE pbid_id >= 6;
DELETE FROM tb_gumaebid WHERE gbid_id >= 4;
DELETE FROM tb_matching WHERE mat_id >= 2;


-----------------------------------���� ����----------------------------------------
[ �Ǹ� ���� ]
1. �Ǹ� ����  -- �����Ǹ� ���� 0, �Ǹſ��� 0
< ��ȸ >
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'lklk9803@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '����6', 0, '������', 1550, null, null);
          
SELECT * FROM tb_panmaebid;

-- ��ü ��ȸ(�̸���)
EXEC pbid_default('lklk9803@gmail.com');

-- �Ⱓ�� ��ȸ(�̸���, ������, ������)
EXEC pbid_date('lklk9803@gmail.com', '2022-05-23', '2022-06-28');
EXEC pbid_date('lklk9803@gmail.com', '2022-08-23', '2022-10-28');


< ����>
-- �Ǹ�������� ����(�̸���, ���Ĺ��)
EXEC pbid_price_order('lklk9803@gmail.com', 0);
EXEC pbid_price_order('lklk9803@gmail.com', 1);

-- �����ϼ� ����(�̸���, ���Ĺ��)
EXEC pbid_exdate_order('lklk9803@gmail.com', 0);
EXEC pbid_exdate_order('lklk9803@gmail.com', 1);

-- �׽�Ʈ ������ ����
DELETE FROM tb_panmaebid WHERE pbid_id = 6;


< ������ ��ǰ ������ >
-- ��ǰ ����, ���� ������ ���� ������ ����
-- ���Ƽ ���� ������ ���� ������ ī�� ������ ����
-- �ݼ� �ּҴ� ���� ������ ��� �ּҿ� ����

-- �Ǹ� ���� ����(�̸���)
EXEC pbid_account('lklk9803@gmail.com');


2. ������  -- �����Ǹ� ���� 0, �Ǹſ��� 1
< ��ȸ >
-- ���º� ��ȸ(�̸���, ��ǰ ����)
EXEC ping_state('sdjsd@naver.com', '�߼ۿ�û');


< ���� >
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'sdjsd@naver.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '����6', 1, '�԰�Ϸ�', 1550, null, null);

-- ���¼� ����(�̸���, ���Ĺ��)
EXEC ping_state_order('sdjsd@naver.com', 0);
EXEC ping_state_order('sdjsd@naver.com', 1);

-- �ѹ�
ROLLBACK;


< ������ ��ǰ ������ >
-- �߼� ���� �̿ܿ� ��� ���� ����

-- �߼� ���� ���(�̸���, �Ǹ����� �ڵ�)
EXEC ping_shipping('hyungjs1234@naver.com', 2);

-- �߼� ���� ����(�Ǹ����� �ڵ�, �ù��, ������ȣ)
EXEC upd_shipping(2, '��ü���ù�', '736132678451');

-- Ȯ�� �� �ѹ�
SELECT * FROM tb_panmaebid;
ROLLBACK;


3. ����  -- �����Ǹ� ���� 0, �Ǹſ��� 2
< ���� >
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '����6', 2, '����Ϸ�', 1550, '�����ù�', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 155000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 2, '��ۿϷ�', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2022/10/20', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 270, 160000
            , TO_DATE('2022/10/18', 'YYYY/MM/DD'), 30, 0, 0, '����6', 2, '����Ϸ�', 1600, '��ü���ù�', '7543135431');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 270, 160000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 2, '��ۿϷ�', 4800, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 7, 5, 0, 270, 160000, TO_DATE('2022/10/18', 'YYYY/MM/DD'), TO_DATE('2022/10/22', 'YYYY/MM/DD'));

-- �����ϼ� ����(�̸���, ���Ĺ��)
EXEC pend_caldate_order('jeifh@gmail.com', 0);
EXEC pend_caldate_order('jeifh@gmail.com', 1);


< ���� ��ǰ ������ >
-- ������ �̿ܿ� ��� ���� ����

-- ������ ���(�ֹ���ȣ)
EXEC pend_caldate(2);

-- �׽�Ʈ ������ ����
DELETE FROM tb_panmaebid WHERE pbid_id >= 6;
DELETE FROM tb_gumaebid WHERE gbid_id >= 4;
DELETE FROM tb_matching WHERE mat_id >= 2;