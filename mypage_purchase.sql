[ ���� ���� ]
< �������� >
-- ���ſ��� 0
1. ��ü ��ȸ
CREATE OR REPLACE PROCEDURE gbid_default
(
    pemail   tb_member.m_email%type
)
IS
    viamge   tb_item.i_image%type;
    vname    tb_item.i_name_eng%type;
    vsize    tb_gumaebid.gbid_size%type;
    vprice   varchar2(20);
    vexdate  varchar2(10);  -- ������
    CURSOR c_gbid IS
                SELECT i_image, i_name_eng, gbid_size
                         , TO_CHAR(gbid_price, 'FM999,999,999,999') || '��' gbid_price
                         , TO_CHAR(gbid_rdate + gbid_deadline, 'YYYY/MM/DD') exdate
                FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id
                WHERE gbid_complete = 0 and m_email = pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE; 
                    -- �Ⱓ �⺻��: �ֱ� 2����
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ���� ���� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ ���� ���� ]');
    DBMS_OUTPUT.PUT_LINE('�Ⱓ: ' || ADD_MONTHS(SYSDATE, -2) || ' ~ ' || SYSDATE || ' (�ֱ� 2����)');
    OPEN c_gbid;
    LOOP
        FETCH c_gbid INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN c_gbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('���������: ' || vprice || ', ������: ' || vexdate);
    END LOOP;
    IF c_gbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('���� ���� ������ �����ϴ�.');
    END IF;
    CLOSE c_gbid;
END;
-- Procedure GBID_DEFAULT��(��) �����ϵǾ����ϴ�.
EXEC gbid_default('shiueo@naver.com');
EXEC gbid_default('lklk9803@gmail.com');


2. �Ⱓ�� ��ȸ
-- �������� �Է��� �����ϰ� ������ ������ ������� ��ȸ
CREATE OR REPLACE PROCEDURE gbid_date
(
    pemail    tb_member.m_email%type
    , psdate  varchar2  -- �Է� ������
    , pedate  varchar2  -- �Է� ������
)
IS
    viamge    tb_item.i_image%type;
    vname     tb_item.i_name_eng%type;
    vsize     tb_gumaebid.gbid_size%type;
    vprice    varchar2(20);
    vexdate   varchar2(10);  -- ������
    CURSOR c_gbid IS
                SELECT i_image, i_name_eng, gbid_size
                         , TO_CHAR(gbid_price, 'FM999,999,999,999') || '��' gbid_price
                         , TO_CHAR(gbid_rdate + gbid_deadline, 'YYYY/MM/DD') exdate
                FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id
                WHERE gbid_complete = 0 and m_email = pemail
                    and gbid_rdate BETWEEN TO_DATE(psdate, 'YYYY-MM-DD') AND TO_DATE(pedate, 'YYYY-MM-DD'); 
BEGIN
    DBMS_OUTPUT.PUT_LINE('[ �Ⱓ�� ��ȸ ]');
    DBMS_OUTPUT.PUT_LINE('�Ⱓ: ' || psdate || ' ~ ' || pedate);
    
    OPEN c_gbid;
    LOOP
        FETCH c_gbid INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN c_gbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('���������: ' || vprice || ', ������: ' || vexdate);
    END LOOP;
    IF c_gbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('���� ���� ������ �����ϴ�.');
    END IF;
    CLOSE c_gbid;
END;
-- Procedure GBID_DATE��(��) �����ϵǾ����ϴ�.
EXEC gbid_date('shiueo@naver.com', '2022-05-23', '2022-06-28');
EXEC gbid_date('shiueo@naver.com', '2022-08-23', '2022-10-28');


3. ����������� ����
CREATE OR REPLACE PROCEDURE gbid_price_order
(
    pemail   tb_member.m_email%type
    , pnum   number  -- 0�̸� ��������, 1�̸� ��������
)
IS
    vsql      varchar2(1000);
    viamge    tb_item.i_image%type;
    vname     tb_item.i_name_eng%type;
    vsize     tb_gumaebid.gbid_size%type;
    vprice    number(12);
    vexdate   date;  -- ������
    vcur      SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, gbid_size, gbid_price, gbid_rdate + gbid_deadline ';
    vsql := vsql || ' FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id ';
    vsql := vsql || ' WHERE gbid_complete = 0 and m_email = :pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ ��������� �������� ���� ]');
        vsql := vsql || ' ORDER BY gbid_price ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ ��������� �������� ���� ]');
        vsql := vsql || ' ORDER BY gbid_price DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('���������: ' || TO_CHAR(vprice, 'FM999,999,999,999')
        || '��, ������: ' || TO_CHAR(vexdate, 'YYYY/MM/DD'));
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('���� ���� ������ �����ϴ�.');
    END IF;
    CLOSE vcur;
END;
-- Procedure GBID_PRICE_ORDER��(��) �����ϵǾ����ϴ�.
EXEC gbid_price_order('shiueo@naver.com', 0);
EXEC gbid_price_order('shiueo@naver.com', 1);
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 165000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 0, '������', 4950, 3000);


4. �����ϼ� ����
CREATE OR REPLACE PROCEDURE gbid_exdate_order
(
    pemail   tb_member.m_email%type
    , pnum   number  -- 0�̸� ��������, 1�̸� ��������
)
IS
    vsql      varchar2(1000);
    viamge    tb_item.i_image%type;
    vname     tb_item.i_name_eng%type;
    vsize     tb_gumaebid.gbid_size%type;
    vprice    number(12);
    vexdate   date;  -- ������
    vcur      SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, gbid_size, gbid_price, gbid_rdate + gbid_deadline AS exdate';
    vsql := vsql || ' FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id ';
    vsql := vsql || ' WHERE gbid_complete = 0 and m_email = :pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
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
        DBMS_OUTPUT.PUT_LINE('���������: ' || TO_CHAR(vprice, 'FM999,999,999,999')
                            || '��, ������: ' || TO_CHAR(vexdate, 'YYYY/MM/DD'));
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('���� ���� ������ �����ϴ�.');
    END IF;
    CLOSE vcur;
END;
-- Procedure GBID_EXDATE_ORDER��(��) �����ϵǾ����ϴ�.
EXEC gbid_exdate_order('shiueo@naver.com', 0);
EXEC gbid_exdate_order('shiueo@naver.com', 1);
-- �׽�Ʈ ������ ����
DELETE FROM tb_gumaebid WHERE gbid_id = 4;


5. ������ ��ǰ ������
5-1. ��ǰ ����
CREATE OR REPLACE PROCEDURE gbid_info1
(
    pemail      tb_member.m_email%type
    , pgumaeid  tb_gumaebid.gbid_id%type
)
IS
    vimage    tb_item.i_image%type;
    vmodel    tb_item.i_model%type;
    vname     tb_item.i_name_eng%type;
    vsize     tb_gumaebid.gbid_size%type;
    vgprice   tb_itemsize.is_gprice%type;
    vpprice   tb_itemsize.is_pprice%type;
BEGIN
    SELECT i_image, i_model, i_name_eng, gbid_size, is_gprice, is_pprice
        INTO vimage, vmodel, vname, vsize, vgprice, vpprice
    FROM (
        SELECT i_image, i_model, i_name_eng, gbid_size
        FROM tb_gumaebid g LEFT JOIN tb_item i ON g.i_id = i.i_id
        WHERE gbid_complete = 0 and m_email = pemail and gbid_id = pgumaeid
    ) t1 JOIN (
        SELECT s_size, is_gprice, is_pprice
        FROM tb_size a LEFT JOIN tb_itemsize b ON a.s_id = b.s_id
    )t2 ON t1.gbid_size = t2.s_size;
    
    DBMS_OUTPUT.PUT_LINE('--- ���� ���� �� ---');
    DBMS_OUTPUT.PUT_LINE('[ ��ǰ ���� ]');
    DBMS_OUTPUT.PUT_LINE('�ֹ���ȣ: ' || pgumaeid);
    DBMS_OUTPUT.PUT_LINE(vimage || chr(10) || vmodel || ', ' || vname || ', ' || vsize);
    DBMS_OUTPUT.PUT_LINE('��ñ��Ű�: ' || TO_CHAR(vgprice, 'FM999,999,999,999') || '��, ����ǸŰ�: ' 
                        || TO_CHAR(vpprice, 'FM999,999,999,999') || '��');
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('--- ���� ���� �� ---');
        DBMS_OUTPUT.PUT_LINE('���� ���� ������ �����ϴ�.');
END;
-- Procedure GBID_INFO1��(��) �����ϵǾ����ϴ�.
EXEC gbid_info1('shiueo@naver.com', 2);


5-2. ���� ���� ����
CREATE OR REPLACE PROCEDURE gbid_info2
(
    pemail      tb_member.m_email%type
    , pgumaeid  tb_gumaebid.gbid_id%type
)
IS
    vprice      tb_gumaebid.gbid_price%type;
    vfee        tb_gumaebid.gbid_fee%type;
    vdelivfee   tb_gumaebid.gbid_deliv_fee%type;
    vrdate      tb_gumaebid.gbid_rdate%type;
    vdeadline   tb_gumaebid.gbid_deadline%type;
BEGIN
    SELECT gbid_price, gbid_fee, gbid_deliv_fee, gbid_rdate, gbid_deadline
        INTO vprice, vfee, vdelivfee, vrdate, vdeadline
    FROM tb_gumaebid
    WHERE gbid_complete = 0 and m_email = pemail and gbid_id = pgumaeid;
    
    DBMS_OUTPUT.PUT_LINE('[ ���� ���� ���� ]');
    DBMS_OUTPUT.PUT_LINE('���� �����: ' || TO_CHAR(vprice, 'FM999,999,999,999') || '��');
    DBMS_OUTPUT.PUT_LINE('�˼���: ����');
    DBMS_OUTPUT.PUT_LINE('������: ' || TO_CHAR(vfee, 'FM999,999,999,999') || '��');
    DBMS_OUTPUT.PUT_LINE('��ۺ�: ' || TO_CHAR(vdelivfee, 'FM999,999,999,999') || '��');
    DBMS_OUTPUT.PUT_LINE('�� �����ݾ�: ' || TO_CHAR(vprice + vfee + vdelivfee, 'FM999,999,999,999') || '��');
    DBMS_OUTPUT.PUT_LINE('������: ' || vrdate);
    DBMS_OUTPUT.PUT_LINE('������������: ' || vdeadline || '�� - ' || TO_CHAR(vrdate + vdeadline, 'YY/MM/DD') || '����');
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('[ ���� ���� ���� ]');
        DBMS_OUTPUT.PUT_LINE('���� ���� ������ �����ϴ�.');
END;
-- Procedure GBID_INFO2��(��) �����ϵǾ����ϴ�.
EXEC gbid_info2('shiueo@naver.com', 2);


5-3. ��� �ּ� �� ���� ����
CREATE OR REPLACE PROCEDURE gbid_info3
(
    pemail  tb_member.m_email%type
)
IS
    vname     tb_delivery.d_name%type;
    vtel      tb_delivery.d_tel%type;
    vzip      tb_delivery.d_zip%type;
    vads      tb_delivery.d_ads%type;
    vdetail   tb_delivery.d_detail%type;
    vbank     tb_card.c_bank%type;
    vcid      tb_card.c_id%type;
BEGIN
    SELECT d_name, d_tel, d_zip, d_ads, d_detail
        INTO vname, vtel, vzip, vads, vdetail
    FROM tb_delivery
    WHERE m_email = pemail and d_basic = 1;  -- �⺻ �����
    
    SELECT c_bank, c_id INTO vbank, vcid
    FROM tb_card
    WHERE m_email = pemail and c_pay = 1; -- �⺻ ���� ī��
    
    DBMS_OUTPUT.PUT_LINE('[ ��� �ּ� ]');
    DBMS_OUTPUT.PUT_LINE('�޴� ���: ' || REPLACE(vname, SUBSTR(vname, 2), '**'));
    DBMS_OUTPUT.PUT_LINE('�޴��� ��ȣ: ' || REPLACE(vtel, SUBSTR(vtel, 6, 5), '***-*'));
    DBMS_OUTPUT.PUT_LINE('�ּ�: (' || vzip || ') ' || vads || ' ' || vdetail);
    DBMS_OUTPUT.PUT_LINE('[ ���� ���� ]');
    DBMS_OUTPUT.PUT_LINE(vbank || ' ****-****-****-' || SUBSTR(vcid, 13, 3) || '*');
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('--- ���� ���� �� ---');
        DBMS_OUTPUT.PUT_LINE('��� �ּ� �� ���� ������ �����ϴ�.');
END;
-- Procedure GBID_INFO3��(��) �����ϵǾ����ϴ�.
EXEC gbid_info3('shiueo@naver.com');

-- ��ü ���
EXEC gbid_info1('shiueo@naver.com', 2);
EXEC gbid_info2('shiueo@naver.com', 2);
EXEC gbid_info3('shiueo@naver.com');


6. ���� ���� �����ϱ�
CREATE OR REPLACE PROCEDURE del_gbid
(
    pgumaeid  tb_gumaebid.gbid_id%type
)
IS
BEGIN
    DELETE FROM tb_gumaebid
    WHERE gbid_id = pgumaeid;
    DBMS_OUTPUT.PUT_LINE('���� ������ �����Ǿ����ϴ�.');
END;
-- Procedure GBID_INFO1��(��) �����ϵǾ����ϴ�.
EXEC del_gbid(3);
ROLLBACK;
SELECT * FROM tb_gumaebid;



< ������ >
-- ���ſ��� 1
1. ���º� ��ȸ
CREATE OR REPLACE PROCEDURE ging_state
(
    pemail       tb_member.m_email%type
    , pitemstate tb_gumaebid.gbid_itemstate%type
)
IS
    viamge  tb_item.i_image%type;
    vname   tb_item.i_name_eng%type;
    vsize   tb_gumaebid.gbid_size%type;
    vstate  tb_gumaebid.gbid_itemstate%type;
    CURSOR c_gbid IS
                SELECT i_image, i_name_eng, gbid_size, gbid_itemstate
                FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id
                WHERE gbid_complete = 1 and m_email = pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE
                    and gbid_itemstate = pitemstate;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ���� ���� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ ���� �� ]');
    DBMS_OUTPUT.PUT_LINE('[ ���º� ��ȸ ]');
    DBMS_OUTPUT.PUT_LINE('������ ����: ' || pitemstate);
    OPEN c_gbid;
    LOOP
        FETCH c_gbid INTO viamge, vname, vsize, vstate;
        EXIT WHEN c_gbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('����: ' || vstate);
    END LOOP;
    IF c_gbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�ŷ� ������ �����ϴ�.');
    END IF;
    CLOSE c_gbid;
END;
-- Procedure GING_STATE��(��) �����ϵǾ����ϴ�.
EXEC ging_state('shiueo@naver.com', '�԰���');
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 165000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 1, '�԰���', 4950, 3000);
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 270, 190000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 1, '��� ��', 5700, 3000);


2. ���¼� ����
CREATE OR REPLACE PROCEDURE ging_state_order
(
    pemail   tb_member.m_email%type
    , pnum   number  -- 0�̸� ��������, 1�̸� ��������
)
IS
    vsql     varchar2(1000);
    viamge   tb_item.i_image%type;
    vname    tb_item.i_name_eng%type;
    vsize    tb_gumaebid.gbid_size%type;
    vstate   tb_gumaebid.gbid_itemstate%type;
    vcur     SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, gbid_size, gbid_itemstate ';
    vsql := vsql || ' FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id ';
    vsql := vsql || ' WHERE gbid_complete = 1 and m_email = :pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ ���� �������� ���� ]');
        vsql := vsql || ' ORDER BY gbid_itemstate ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ ���� �������� ���� ]');
        vsql := vsql || ' ORDER BY gbid_itemstate DESC ';
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
-- Procedure GING_STATE_ORDER��(��) �����ϵǾ����ϴ�.
EXEC ging_state_order('shiueo@naver.com', 0);
EXEC ging_state_order('shiueo@naver.com', 1);
-- �׽�Ʈ ������ ����
DELETE FROM tb_gumaebid WHERE gbid_id IN (5, 6);


3. ������ ��ǰ ������
3-1. ��ǰ ����
CREATE OR REPLACE PROCEDURE ging_info1
(
    pemail    tb_member.m_email%type
    , pmatid  tb_matching.mat_id%type
)
IS
    vimage      tb_item.i_image%type;
    vmodel      tb_item.i_model%type;
    vname       tb_item.i_name_eng%type;
    vsize       tb_gumaebid.gbid_size%type;
    vitemstate  tb_gumaebid.gbid_itemstate%type;
BEGIN
    SELECT i_image, i_model, i_name_eng, gbid_size, gbid_itemstate
        INTO vimage, vmodel, vname, vsize, vitemstate
    FROM tb_gumaebid g LEFT JOIN tb_item i ON g.i_id = i.i_id
                       JOIN tb_matching m ON g.gbid_id = m.gbid_id
    WHERE gbid_complete = 1 and g.gbid_id = m.gbid_id and mat_id = pmatid;
    
    DBMS_OUTPUT.PUT_LINE('--- ���� ���� �� ---');
    DBMS_OUTPUT.PUT_LINE('[ ��ǰ ���� ]');
    DBMS_OUTPUT.PUT_LINE('�ֹ���ȣ: ' || pmatid);
    DBMS_OUTPUT.PUT_LINE(vimage || chr(10) || vmodel || ', ' || vname || ', ' || vsize);
    DBMS_OUTPUT.PUT_LINE('�����Ȳ: ' || vitemstate);
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('--- ���� ���� �� ---');
        DBMS_OUTPUT.PUT_LINE('���� ���� �� ��ǰ�� �����ϴ�.');
END;
-- Procedure GBID_INFO1��(��) �����ϵǾ����ϴ�.
EXEC ging_info1('hyungjs1234@naver.com', 2);
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '����6', 1, '�԰���', 1550, '�����ù�', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'hyungjs1234@naver.com', 1, 240, 155000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 1, '�԰���', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2022/10/20', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 270, 160000
            , TO_DATE('2022/10/18', 'YYYY/MM/DD'), 30, 0, 0, '����6', 1, '�߼ۿ�û', 1600, '��ü���ù�', '7543135431');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'hyungjs1234@naver.com', 1, 270, 160000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 1, '�����', 4800, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 7, 5, 0, 270, 160000, TO_DATE('2022/10/18', 'YYYY/MM/DD'), TO_DATE('2022/10/22', 'YYYY/MM/DD'));

ROLLBACK;

SELECT * FROM tb_panmaebid;
SELECT * FROM tb_gumaebid;
SELECT * FROM tb_matching;
  
  
3-2. ���� ����
CREATE OR REPLACE PROCEDURE ging_info2
(
    pemail    tb_member.m_email%type
    , pmatid  tb_matching.mat_id%type
)
IS
    vprice      tb_matching.mat_price%type;
    vfee        tb_gumaebid.gbid_fee%type;
    vdelivfee   tb_gumaebid.gbid_deliv_fee%type;
    vmatdate    tb_matching.mat_date%type;
BEGIN
    SELECT mat_price, gbid_fee, gbid_deliv_fee, mat_date
        INTO vprice, vfee, vdelivfee, vmatdate
    FROM tb_matching m JOIN tb_gumaebid g ON m.gbid_id = g.gbid_id
    WHERE gbid_complete = 1 and g.gbid_id = m.gbid_id and mat_id = pmatid;
    
    DBMS_OUTPUT.PUT_LINE('�� �����ݾ�: ' || TO_CHAR(vprice + vfee + vdelivfee, 'FM999,999,999,999') || '��');
    DBMS_OUTPUT.PUT_LINE('�˼���: ����');
    DBMS_OUTPUT.PUT_LINE('������: ' || TO_CHAR(vfee, 'FM999,999,999,999') || '��');
    DBMS_OUTPUT.PUT_LINE('��ۺ�: ' || TO_CHAR(vdelivfee, 'FM999,999,999,999') || '��');
    DBMS_OUTPUT.PUT_LINE('�ŷ��Ͻ�: ' || TO_CHAR(vmatdate, 'YY/MM/DD HH24:MI'));
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('--- ���� ���� �� ---');
        DBMS_OUTPUT.PUT_LINE('���� ���� �� ��ǰ�� �����ϴ�.');
END;
-- Procedure GING_INFO2��(��) �����ϵǾ����ϴ�.
EXEC ging_info2('hyungjs1234@naver.com', 2);


< ���� >
-- ���ſ��� 2
1. �����ϼ�(�ŷ��ϼ�) ����
CREATE OR REPLACE PROCEDURE gend_matdate_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0�̸� ��������, 1�̸� ��������
)
IS
    vsql        varchar2(1000);
    viamge      tb_item.i_image%type;
    vname       tb_item.i_name_eng%type;
    vsize       tb_gumaebid.gbid_size%type;
    vmatdate    tb_matching.mat_date%type;
    vstate      tb_gumaebid.gbid_itemstate%type;
    vcur        SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, gbid_size, mat_date, gbid_itemstate ';
    vsql := vsql || ' FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id
                                     JOIN tb_matching m ON g.gbid_id = m.gbid_id ';
    vsql := vsql || ' WHERE gbid_complete = 2 and m_email = :pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    DBMS_OUTPUT.PUT_LINE('--- ���� ���� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ ���� ]');
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ ������ �������� ���� ]');
        vsql := vsql || ' ORDER BY mat_date ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ ������ �������� ���� ]');
        vsql := vsql || ' ORDER BY mat_date DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vmatdate, vstate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('������: ' || vmatdate || ', ����: ' || vstate);
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�ŷ� ������ �����ϴ�.');
    END IF;
    CLOSE vcur;
END;
-- Procedure GEND_MATDATE_ORDER��(��) �����ϵǾ����ϴ�.
EXEC gend_matdate_order('shiueo@naver.com', 0);
EXEC gend_matdate_order('shiueo@naver.com', 1);

-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '����6', 2, '����Ϸ�', 1550, '�����ù�', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 155000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 2, '��ۿϷ�', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2022/10/20', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

ROLLBACK;


2. ���� ��ǰ ������
-- ������ ��ǰ �������� ����


------------------------------------���� ����---------------------------------------
[ ���� ���� ������ ]
1. ���� ����  -- ���ſ��� 0
< ��ȸ >
-- ��ü ��ȸ(�̸���)
EXEC gbid_default('shiueo@naver.com');

-- �Ⱓ�� ��ȸ(�̸���, ������, ������)
EXEC gbid_date('shiueo@naver.com', '2022-05-23', '2022-06-28');
EXEC gbid_date('shiueo@naver.com', '2022-08-23', '2023-1-11');


< ���� >
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 165000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 0, '������', 4950, 3000);
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 165000
            , TO_DATE('2022/12/20', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 0, '������', 4950, 3000);
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 250, 170000
            , TO_DATE('2023/01/05', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 0, '������', 4950, 3000);

-- ����������� ����(�̸���, ���Ĺ��)
-- 0�̸� ��������, 1�̸� ��������(���� ���� ����)
EXEC gbid_price_order('shiueo@naver.com', 0);
EXEC gbid_price_order('shiueo@naver.com', 1);

-- �����ϼ� ����(�̸���, ���Ĺ��)
EXEC gbid_exdate_order('shiueo@naver.com', 0);
EXEC gbid_exdate_order('shiueo@naver.com', 1);

-- �׽�Ʈ ������ ����
DELETE FROM tb_gumaebid WHERE gbid_id >= 4;


< ������ ��ǰ ������ ��� >
-- ��ǰ����(�̸���, �������� �ڵ�)
EXEC gbid_info1('shiueo@naver.com', 2);

-- ���� ���� ����(�̸���, �������� �ڵ�)
EXEC gbid_info2('shiueo@naver.com', 2);

-- ��� �ּ� �� ���� ����(�̸���)
EXEC gbid_info3('shiueo@naver.com');


< ���� ���� ���� >
-- ���� ���� ����(�������� �ڵ�) 
EXEC del_gbid(3);

-- Ȯ�� �� �ѹ�
ROLLBACK;
SELECT * FROM tb_gumaebid;


2. ������  -- ���ſ��� 1
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 165000
            , TO_DATE('2023/1/1', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 1, '�԰���', 4950, 3000);
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 270, 190000
            , TO_DATE('2023/1/8', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 1, '��� ��', 5700, 3000);


< ��ȸ >
-- ���º� ��ȸ(�̸���, ��ǰ ����)
EXEC ging_state('shiueo@naver.com', '�԰���');


< ���� >
-- ���¼� ����(�̸���, ���Ĺ��)
EXEC ging_state_order('shiueo@naver.com', 0);
EXEC ging_state_order('shiueo@naver.com', 1);

-- �׽�Ʈ ������ ����
DELETE FROM tb_gumaebid WHERE gbid_id IN (4, 5);
commit;

< ������ ��ǰ ������ >
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '����6', 1, '�԰���', 1550, '�����ù�', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'hyungjs1234@naver.com', 1, 240, 155000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 1, '�԰���', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2022/10/20', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 270, 160000
            , TO_DATE('2022/10/18', 'YYYY/MM/DD'), 30, 0, 0, '����6', 1, '�߼ۿ�û', 1600, '��ü���ù�', '7543135431');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'hyungjs1234@naver.com', 1, 270, 160000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 1, '�����', 4800, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 7, 5, 0, 270, 160000, TO_DATE('2022/10/18', 'YYYY/MM/DD'), TO_DATE('2022/10/22', 'YYYY/MM/DD'));

-- Ȯ�� �� �ѹ�
SELECT * FROM tb_panmaebid;
SELECT * FROM tb_gumaebid;
SELECT * FROM tb_matching;
ROLLBACK;
  
-- ��ǰ ����(�̸���, �ֹ���ȣ)
EXEC ging_info1('hyungjs1234@naver.com', 2);

-- ���� ����(�̸���, �ֹ���ȣ)
EXEC ging_info2('hyungjs1234@naver.com', 2);


3. ����  -- ���ſ��� 2
< ���� >
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2023/1/1', 'YYYY/MM/DD'), 30, 0, 0, '����6', 2, '����Ϸ�', 1550, '�����ù�', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 155000
            , TO_DATE('2023/1/5', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 2, '��ۿϷ�', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2023/1/5', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 230, 160000
            , TO_DATE('2023/1/3', 'YYYY/MM/DD'), 30, 0, 0, '����6', 2, '����Ϸ�', 1550, '�����ù�', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 160000
            , TO_DATE('2023/1/6', 'YYYY/MM/DD'), 30, 1, '�Ϲݹ��', '����', 0, 2, '��ۿϷ�', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 230, 155000, TO_DATE('2023/1/6', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));


-- �����ϼ�(�ŷ��ϼ�) ����(�̸���, ���Ĺ��)
EXEC gend_matdate_order('shiueo@naver.com', 0);
EXEC gend_matdate_order('shiueo@naver.com', 1);

-- �ѹ�
ROLLBACK;

select * from tb_gumaebid;

< ���� ��ǰ ������ >
-- ������ ��ǰ �������� ����
