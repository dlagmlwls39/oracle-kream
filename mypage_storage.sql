[ ���� �Ǹ� ] -- ��ü ��ȸ �Ұ�. ���º��θ� ��ȸ ����.
-- ������
CREATE SEQUENCE bpi_id INCREMENT BY 1 START WITH 4;

------------------------------------------------------------

< ���� ��ǰ ���� >
CREATE OR REPLACE PROCEDURE bpan_itemlist
IS
    vimage      tb_item.i_image%type;
    vmodel      tb_item.i_model%type;
    vname_eng   tb_item.i_name_eng%type;
    vname_kor   tb_item.i_name_kor%type;
    CURSOR c_bpan IS
                SELECT i_image, i_model, i_name_eng, i_name_kor
                FROM tb_item i 
                WHERE i_bpcheck = 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ���� ��ǰ ���� ---');
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname_eng, vname_kor;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || chr(10) || vmodel || chr(10)
                            || vname_eng || chr(10) || vname_kor);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------');
    END LOOP;
    CLOSE c_bpan;
END;
-- Procedure BPAN_ITEMLIST��(��) �����ϵǾ����ϴ�.
EXEC bpan_itemlist;


< ��û >
-- �����Ǹ� ���� 1, �Ǹſ��� 0
1. ���º� ��ȸ (default�� �߼ۿ�û)
CREATE OR REPLACE PROCEDURE bpan_app
(
    pemail      tb_member.m_email%type
    , pstate    tb_panmaebid.pbid_itemstate%type
)
IS
    vimage       tb_item.i_image%type;
    vmodel       tb_item.i_model%type;
    vname        tb_item.i_name_eng%type;
    vsize        tb_gumaebid.gbid_size%type;
    vbpi_id      tb_bpanitem.bpi_id%type;
    vdeposit     tb_bpanitem.bpi_deposit%type;
    vcourier     tb_panmaebid.pbid_courier%type;
    vtrackingnum tb_panmaebid.pbid_trackingnum%type;
    CURSOR c_bpan IS
                SELECT i_image, i_model, i_name_eng, pbid_size, bpi_id
                        , bpi_deposit, pbid_courier, pbid_trackingnum
                FROM tb_panmaebid p LEFT JOIN tb_item i ON p.i_id = i.i_id
                                    LEFT JOIN tb_bpanitem b ON p.pbid_id = b.pbid_id
                WHERE pbid_keepcheck = 1 and pbid_complete = 0 and m_email = pemail;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ���� �Ǹ� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ ��û ]');
    DBMS_OUTPUT.PUT_LINE('[ ���º� ��ȸ ]');
    DBMS_OUTPUT.PUT_LINE('������ ����: ' || pstate);
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('������: ' || vsize || ', ������: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('�ù��: ' || vcourier || ', ����� ��ȣ: ' || vtrackingnum);
    END LOOP;
    IF c_bpan%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �����ϴ�.');
    END IF;
    CLOSE c_bpan;
END;
-- Procedure BPAN_APP��(��) �����ϵǾ����ϴ�.
EXEC bpan_app('shiueo@naver.com', '�߼ۿ�û');
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'shiueo@naver.com', 1, null, 280, 180000
            , TO_DATE('23/01/01', 'YY/MM/DD'), 30, 0, 1, '����8', 0, '�߼ۿ�û', 1800, null, null); 
INSERT INTO tb_bpanitem VALUES (bpi_id.nextval, 26, 1, 0, 3000);

select * from tb_bpanitem;
select * from tb_panmaebid;

2. �ù��, ������ȣ �Է�
CREATE OR REPLACE PROCEDURE upd_shipping 
(
    ppbid_id        tb_panmaebid.pbid_id%type  -- �Ǹ����� �ڵ�
    , pcourier      tb_panmaebid.pbid_courier%type
    , ptrackingnum  tb_panmaebid.pbid_trackingnum%type
)
IS
BEGIN
    UPDATE tb_panmaebid
    SET pbid_courier = pcourier, pbid_trackingnum = ptrackingnum
    WHERE pbid_id = ppbid_id;
END;
-- Procedure UPD_SHIPPING��(��) �����ϵǾ����ϴ�.
EXEC upd_shipping(26, '��ü���ù�', '516873151354');

EXEC bpan_app('shiueo@naver.com', '�߼ۿ�û');

-- �׽�Ʈ ������ ����
DELETE FROM tb_panmaebid
WHERE pbid_id = 8;
DELETE FROM tb_bpanitem
WHERE bpi_id = 4;
COMMIT;


3. ��û ���
CREATE OR REPLACE PROCEDURE del_bpan 
(
    pbpi_id   tb_bpanitem.bpi_id%type  -- ���� ��ǰ �ڵ�
)
IS
    vpbid_id  tb_panmaebid.pbid_id%type;
BEGIN
    SELECT a.pbid_id INTO vpbid_id
    FROM tb_bpanitem a JOIN tb_panmaebid b ON a.pbid_id = b.pbid_id
    WHERE bpi_id = pbpi_id;
    
    -- ���� �Ǹ� ��ǰ ���̺��� ����
    DELETE FROM tb_bpanitem
    WHERE bpi_id = pbpi_id;
    
    -- �Ǹ� ���� ���̺��� ����
    DELETE FROM tb_panmaebid
    WHERE pbid_id = vpbid_id;
    
    DBMS_OUTPUT.PUT_LINE('���� �Ǹ� ��û�� ��ҵǾ����ϴ�.');
END;
--Procedure DEL_BPAN��(��) �����ϵǾ����ϴ�.
EXEC del_bpan(4);
-- �׽�Ʈ ������ �߰�
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'shiueo@naver.com', 1, null, 280, 180000
            , TO_DATE('23/01/01', 'YY/MM/DD'), 30, 0, 1, '����8', 0, '�߼ۿ�û', 1800, null, null); 
INSERT INTO tb_bpanitem VALUES (bpi_id.nextval, 27, 1, 0, 3000);

SELECT * FROM tb_bpanitem;
SELECT * FROM tb_panmaebid;



< ������ >
-- �����Ǹ� ���� 1, �Ǹſ��� 1
1. ���º� ��ȸ (default�� �ǸŴ��)
CREATE OR REPLACE PROCEDURE bpan_ing
(
    pemail      tb_member.m_email%type
    , pstate    tb_panmaebid.pbid_itemstate%type
)
IS
    vimage       tb_item.i_image%type;
    vmodel       tb_item.i_model%type;
    vname        tb_item.i_name_eng%type;
    vsize        tb_gumaebid.gbid_size%type;
    vbpi_id      tb_bpanitem.bpi_id%type;
    vdeposit     tb_bpanitem.bpi_deposit%type;
    vcourier     tb_panmaebid.pbid_courier%type;
    vtrackingnum tb_panmaebid.pbid_trackingnum%type;
    CURSOR c_bpan IS
                SELECT i_image, i_model, i_name_eng, pbid_size, bpi_id
                        , bpi_deposit, pbid_courier, pbid_trackingnum
                FROM tb_panmaebid p LEFT JOIN tb_item i ON p.i_id = i.i_id
                                    LEFT JOIN tb_bpanitem b ON p.pbid_id = b.pbid_id
                WHERE pbid_keepcheck = 1 and pbid_complete = 1 and m_email = pemail;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ���� �Ǹ� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ ���� �� ]');
    DBMS_OUTPUT.PUT_LINE('[ ���º� ��ȸ ]');
    DBMS_OUTPUT.PUT_LINE('������ ����: ' || pstate);
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('������: ' || vsize || ', ������: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('�ù��: ' || vcourier || ', ����� ��ȣ: ' || vtrackingnum);
    END LOOP;
    IF c_bpan%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �����ϴ�.');
    END IF;
    CLOSE c_bpan;
END;
-- Procedure BPAN_ING��(��) �����ϵǾ����ϴ�.
EXEC bpan_ing('hyungjs1234@naver.com', '�Ǹ���');


2. �հ�/95�� �հݺ� ��ȸ
CREATE OR REPLACE PROCEDURE bpan_ing_pass
(
    pemail  tb_member.m_email%type
    , pis95 number  -- 0�̸� �հ� ��ǰ, 1�̸� 95�� ��ǰ
)
IS
    vsql         varchar2(1000);
    vimage       tb_item.i_image%type;
    vmodel       tb_item.i_model%type;
    vname        tb_item.i_name_eng%type;
    vsize        tb_gumaebid.gbid_size%type;
    vbpi_id      tb_bpanitem.bpi_id%type;
    vdeposit     tb_bpanitem.bpi_deposit%type;
    vcourier     tb_panmaebid.pbid_courier%type;
    vtrackingnum tb_panmaebid.pbid_trackingnum%type;
    vcur         SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_model, i_name_eng, pbid_size, bpi_id
                        , bpi_deposit, pbid_courier, pbid_trackingnum ';
    vsql := vsql || ' FROM tb_panmaebid p LEFT JOIN tb_item i ON p.i_id = i.i_id
                                          LEFT JOIN tb_bpanitem b ON p.pbid_id = b.pbid_id ';
    vsql := vsql || ' WHERE pbid_keepcheck = 1 and pbid_complete = 1 
                            and bpi_inspect = 1 and m_email = :pemail ';
    
    IF pis95 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ �հ� ]');
        vsql := vsql || ' and pbid_95check = 0 ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 95�� �հ� ]');
        vsql := vsql || ' and pbid_95check = 1 ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('������: ' || vsize || ', ������: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('�ù��: ' || vcourier || ', ����� ��ȣ: ' || vtrackingnum);
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �����ϴ�.');
    END IF;
    CLOSE vcur;
END;
-- Procedure BPAN_ING_PASS��(��) �����ϵǾ����ϴ�.
EXEC bpan_ing_pass('hyungjs1234@naver.com', 0);
EXEC bpan_ing_pass('hyungjs1234@naver.com', 1);


< ���� >
-- �����Ǹ� ���� 1, �Ǹſ��� 2
1. ���º� ��ȸ (default�� ����Ϸ�)
CREATE OR REPLACE PROCEDURE bpan_end
(
    pemail      tb_member.m_email%type
    , pstate    tb_panmaebid.pbid_itemstate%type
)
IS
    vimage       tb_item.i_image%type;
    vmodel       tb_item.i_model%type;
    vname        tb_item.i_name_eng%type;
    vsize        tb_gumaebid.gbid_size%type;
    vbpi_id      tb_bpanitem.bpi_id%type;
    vdeposit     tb_bpanitem.bpi_deposit%type;
    vcourier     tb_panmaebid.pbid_courier%type;
    vtrackingnum tb_panmaebid.pbid_trackingnum%type;
    CURSOR c_bpan IS
                SELECT i_image, i_model, i_name_eng, pbid_size, bpi_id
                        , bpi_deposit, pbid_courier, pbid_trackingnum
                FROM tb_panmaebid p LEFT JOIN tb_item i ON p.i_id = i.i_id
                                    LEFT JOIN tb_bpanitem b ON p.pbid_id = b.pbid_id
                WHERE pbid_keepcheck = 1 and pbid_complete = 2 and m_email = pemail;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ���� �Ǹ� ������ ---');
    DBMS_OUTPUT.PUT_LINE('[ ���� ]');
    DBMS_OUTPUT.PUT_LINE('[ ���º� ��ȸ ]');
    DBMS_OUTPUT.PUT_LINE('������ ����: ' || pstate);
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('������: ' || vsize || ', ������: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('�ù��: ' || vcourier || ', ����� ��ȣ: ' || vtrackingnum);
    END LOOP;
    IF c_bpan%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �����ϴ�.');
    END IF;
    CLOSE c_bpan;
END;
-- Procedure BPAN_END��(��) �����ϵǾ����ϴ�.
EXEC bpan_end('jeifh@gmail.com', '����Ϸ�');



< �˻� >
-- ��û: pbid_keepcheck = 1 and pbid_complete = 0
-- ���� ��: pbid_keepcheck = 1 and pbid_complete = 1
-- ����: pbid_keepcheck = 1 and pbid_complete = 2
CREATE OR REPLACE PROCEDURE bpan_search
(   
    pemail      tb_member.m_email%type
    , pkeyword  varchar2
)
IS
    vsql         varchar2(1000);
    vimage       tb_item.i_image%type;
    vmodel       tb_item.i_model%type;
    vname        tb_item.i_name_eng%type;
    vsize        tb_gumaebid.gbid_size%type;
    vbpi_id      tb_bpanitem.bpi_id%type;
    vdeposit     tb_bpanitem.bpi_deposit%type;
    vcourier     tb_panmaebid.pbid_courier%type;
    vtrackingnum tb_panmaebid.pbid_trackingnum%type;
    CURSOR c_bpan IS
                    SELECT i_image, i_model, i_name_eng, pbid_size, bpi_id
                            , bpi_deposit, pbid_courier, pbid_trackingnum 
                    FROM tb_panmaebid p JOIN tb_item i ON p.i_id = i.i_id
                                        JOIN tb_bpanitem b ON p.pbid_id = b.pbid_id 
                    WHERE pbid_keepcheck = 1 and pbid_complete = 1 and m_email = pemail 
                        and ( (i_brand LIKE '%' || pkeyword || '%')
                        or (i_name_eng LIKE '%' || pkeyword || '%')
                        or (i_model LIKE '%' || pkeyword || '%') );
BEGIN
    DBMS_OUTPUT.PUT_LINE('[ ���� �Ǹ� �˻� ]');
    DBMS_OUTPUT.PUT_LINE('�˻���: ' || pkeyword);
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('������: ' || vsize || ', ������: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('�ù��: ' || vcourier || ', ����� ��ȣ: ' || vtrackingnum);
    END LOOP;
    IF c_bpan%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �����ϴ�.');
    END IF;
    CLOSE c_bpan;     
END;   
-- Procedure BPAN_SEARCH��(��) �����ϵǾ����ϴ�.
-- �ùٸ� ��)
EXEC bpan_search('hyungjs1234@naver.com', 'NIK');  -- NIKE
EXEC bpan_search('hyungjs1234@naver.com', 'Air Force');  -- Nike Air Force 1 '07 Low White
EXEC bpan_search('hyungjs1234@naver.com', 'CW2288');  -- 315122-111/CW2288-111
-- �߸��� ��)
EXEC bpan_search('hyungjs1234@naver.com', 'Air Fo2ce');  -- ������ �����ϴ�.
EXEC bpan_search('hyungjs1234@naver.com', 'CW8822');  -- ������ �����ϴ�.
