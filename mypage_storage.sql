[ 보관 판매 ] -- 전체 조회 불가. 상태별로만 조회 가능.
-- 시퀀스
CREATE SEQUENCE bpi_id INCREMENT BY 1 START WITH 4;

------------------------------------------------------------

< 보관 상품 선택 >
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
    DBMS_OUTPUT.PUT_LINE('--- 보관 상품 선택 ---');
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
-- Procedure BPAN_ITEMLIST이(가) 컴파일되었습니다.
EXEC bpan_itemlist;


< 신청 >
-- 보관판매 여부 1, 판매여부 0
1. 상태별 조회 (default는 발송요청)
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
    DBMS_OUTPUT.PUT_LINE('--- 보관 판매 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 신청 ]');
    DBMS_OUTPUT.PUT_LINE('[ 상태별 조회 ]');
    DBMS_OUTPUT.PUT_LINE('선택한 상태: ' || pstate);
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('사이즈: ' || vsize || ', 보증금: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('택배사: ' || vcourier || ', 운송장 번호: ' || vtrackingnum);
    END LOOP;
    IF c_bpan%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('내역이 없습니다.');
    END IF;
    CLOSE c_bpan;
END;
-- Procedure BPAN_APP이(가) 컴파일되었습니다.
EXEC bpan_app('shiueo@naver.com', '발송요청');
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'shiueo@naver.com', 1, null, 280, 180000
            , TO_DATE('23/01/01', 'YY/MM/DD'), 30, 0, 1, '집앞8', 0, '발송요청', 1800, null, null); 
INSERT INTO tb_bpanitem VALUES (bpi_id.nextval, 26, 1, 0, 3000);

select * from tb_bpanitem;
select * from tb_panmaebid;

2. 택배사, 운송장번호 입력
CREATE OR REPLACE PROCEDURE upd_shipping 
(
    ppbid_id        tb_panmaebid.pbid_id%type  -- 판매입찰 코드
    , pcourier      tb_panmaebid.pbid_courier%type
    , ptrackingnum  tb_panmaebid.pbid_trackingnum%type
)
IS
BEGIN
    UPDATE tb_panmaebid
    SET pbid_courier = pcourier, pbid_trackingnum = ptrackingnum
    WHERE pbid_id = ppbid_id;
END;
-- Procedure UPD_SHIPPING이(가) 컴파일되었습니다.
EXEC upd_shipping(26, '우체국택배', '516873151354');

EXEC bpan_app('shiueo@naver.com', '발송요청');

-- 테스트 데이터 삭제
DELETE FROM tb_panmaebid
WHERE pbid_id = 8;
DELETE FROM tb_bpanitem
WHERE bpi_id = 4;
COMMIT;


3. 신청 취소
CREATE OR REPLACE PROCEDURE del_bpan 
(
    pbpi_id   tb_bpanitem.bpi_id%type  -- 보관 상품 코드
)
IS
    vpbid_id  tb_panmaebid.pbid_id%type;
BEGIN
    SELECT a.pbid_id INTO vpbid_id
    FROM tb_bpanitem a JOIN tb_panmaebid b ON a.pbid_id = b.pbid_id
    WHERE bpi_id = pbpi_id;
    
    -- 보관 판매 상품 테이블에서 삭제
    DELETE FROM tb_bpanitem
    WHERE bpi_id = pbpi_id;
    
    -- 판매 입찰 테이블에서 삭제
    DELETE FROM tb_panmaebid
    WHERE pbid_id = vpbid_id;
    
    DBMS_OUTPUT.PUT_LINE('보관 판매 신청이 취소되었습니다.');
END;
--Procedure DEL_BPAN이(가) 컴파일되었습니다.
EXEC del_bpan(4);
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'shiueo@naver.com', 1, null, 280, 180000
            , TO_DATE('23/01/01', 'YY/MM/DD'), 30, 0, 1, '집앞8', 0, '발송요청', 1800, null, null); 
INSERT INTO tb_bpanitem VALUES (bpi_id.nextval, 27, 1, 0, 3000);

SELECT * FROM tb_bpanitem;
SELECT * FROM tb_panmaebid;



< 보관중 >
-- 보관판매 여부 1, 판매여부 1
1. 상태별 조회 (default는 판매대기)
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
    DBMS_OUTPUT.PUT_LINE('--- 보관 판매 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 보관 중 ]');
    DBMS_OUTPUT.PUT_LINE('[ 상태별 조회 ]');
    DBMS_OUTPUT.PUT_LINE('선택한 상태: ' || pstate);
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('사이즈: ' || vsize || ', 보증금: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('택배사: ' || vcourier || ', 운송장 번호: ' || vtrackingnum);
    END LOOP;
    IF c_bpan%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('내역이 없습니다.');
    END IF;
    CLOSE c_bpan;
END;
-- Procedure BPAN_ING이(가) 컴파일되었습니다.
EXEC bpan_ing('hyungjs1234@naver.com', '판매중');


2. 합격/95점 합격별 조회
CREATE OR REPLACE PROCEDURE bpan_ing_pass
(
    pemail  tb_member.m_email%type
    , pis95 number  -- 0이면 합격 상품, 1이면 95점 상품
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
        DBMS_OUTPUT.PUT_LINE('[ 합격 ]');
        vsql := vsql || ' and pbid_95check = 0 ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 95점 합격 ]');
        vsql := vsql || ' and pbid_95check = 1 ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('사이즈: ' || vsize || ', 보증금: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('택배사: ' || vcourier || ', 운송장 번호: ' || vtrackingnum);
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('내역이 없습니다.');
    END IF;
    CLOSE vcur;
END;
-- Procedure BPAN_ING_PASS이(가) 컴파일되었습니다.
EXEC bpan_ing_pass('hyungjs1234@naver.com', 0);
EXEC bpan_ing_pass('hyungjs1234@naver.com', 1);


< 종료 >
-- 보관판매 여부 1, 판매여부 2
1. 상태별 조회 (default는 정산완료)
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
    DBMS_OUTPUT.PUT_LINE('--- 보관 판매 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 종료 ]');
    DBMS_OUTPUT.PUT_LINE('[ 상태별 조회 ]');
    DBMS_OUTPUT.PUT_LINE('선택한 상태: ' || pstate);
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('사이즈: ' || vsize || ', 보증금: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('택배사: ' || vcourier || ', 운송장 번호: ' || vtrackingnum);
    END LOOP;
    IF c_bpan%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('내역이 없습니다.');
    END IF;
    CLOSE c_bpan;
END;
-- Procedure BPAN_END이(가) 컴파일되었습니다.
EXEC bpan_end('jeifh@gmail.com', '정산완료');



< 검색 >
-- 신청: pbid_keepcheck = 1 and pbid_complete = 0
-- 보관 중: pbid_keepcheck = 1 and pbid_complete = 1
-- 종료: pbid_keepcheck = 1 and pbid_complete = 2
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
    DBMS_OUTPUT.PUT_LINE('[ 보관 판매 검색 ]');
    DBMS_OUTPUT.PUT_LINE('검색어: ' || pkeyword);
    OPEN c_bpan;
    LOOP
        FETCH c_bpan INTO vimage, vmodel, vname, vsize, vbpi_id, vdeposit, vcourier, vtrackingnum;
        EXIT WHEN c_bpan%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vimage || ', ' || vmodel || ', ' || vname || ', ' || vbpi_id);
        DBMS_OUTPUT.PUT_LINE('사이즈: ' || vsize || ', 보증금: ' || vdeposit);
        DBMS_OUTPUT.PUT_LINE('택배사: ' || vcourier || ', 운송장 번호: ' || vtrackingnum);
    END LOOP;
    IF c_bpan%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('내역이 없습니다.');
    END IF;
    CLOSE c_bpan;     
END;   
-- Procedure BPAN_SEARCH이(가) 컴파일되었습니다.
-- 올바른 예)
EXEC bpan_search('hyungjs1234@naver.com', 'NIK');  -- NIKE
EXEC bpan_search('hyungjs1234@naver.com', 'Air Force');  -- Nike Air Force 1 '07 Low White
EXEC bpan_search('hyungjs1234@naver.com', 'CW2288');  -- 315122-111/CW2288-111
-- 잘못된 예)
EXEC bpan_search('hyungjs1234@naver.com', 'Air Fo2ce');  -- 내역이 없습니다.
EXEC bpan_search('hyungjs1234@naver.com', 'CW8822');  -- 내역이 없습니다.
