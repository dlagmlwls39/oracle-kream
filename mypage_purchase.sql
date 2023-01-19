[ 구매 내역 ]
< 구매입찰 >
-- 구매여부 0
1. 전체 조회
CREATE OR REPLACE PROCEDURE gbid_default
(
    pemail   tb_member.m_email%type
)
IS
    viamge   tb_item.i_image%type;
    vname    tb_item.i_name_eng%type;
    vsize    tb_gumaebid.gbid_size%type;
    vprice   varchar2(20);
    vexdate  varchar2(10);  -- 만료일
    CURSOR c_gbid IS
                SELECT i_image, i_name_eng, gbid_size
                         , TO_CHAR(gbid_price, 'FM999,999,999,999') || '원' gbid_price
                         , TO_CHAR(gbid_rdate + gbid_deadline, 'YYYY/MM/DD') exdate
                FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id
                WHERE gbid_complete = 0 and m_email = pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE; 
                    -- 기간 기본값: 최근 2개월
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 구매 내역 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 구매 입찰 ]');
    DBMS_OUTPUT.PUT_LINE('기간: ' || ADD_MONTHS(SYSDATE, -2) || ' ~ ' || SYSDATE || ' (최근 2개월)');
    OPEN c_gbid;
    LOOP
        FETCH c_gbid INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN c_gbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('구매희망가: ' || vprice || ', 만료일: ' || vexdate);
    END LOOP;
    IF c_gbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('구매 입찰 내역이 없습니다.');
    END IF;
    CLOSE c_gbid;
END;
-- Procedure GBID_DEFAULT이(가) 컴파일되었습니다.
EXEC gbid_default('shiueo@naver.com');
EXEC gbid_default('lklk9803@gmail.com');


2. 기간별 조회
-- 입찰일이 입력한 시작일과 종료일 사이인 입찰목록 조회
CREATE OR REPLACE PROCEDURE gbid_date
(
    pemail    tb_member.m_email%type
    , psdate  varchar2  -- 입력 시작일
    , pedate  varchar2  -- 입력 종료일
)
IS
    viamge    tb_item.i_image%type;
    vname     tb_item.i_name_eng%type;
    vsize     tb_gumaebid.gbid_size%type;
    vprice    varchar2(20);
    vexdate   varchar2(10);  -- 만료일
    CURSOR c_gbid IS
                SELECT i_image, i_name_eng, gbid_size
                         , TO_CHAR(gbid_price, 'FM999,999,999,999') || '원' gbid_price
                         , TO_CHAR(gbid_rdate + gbid_deadline, 'YYYY/MM/DD') exdate
                FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id
                WHERE gbid_complete = 0 and m_email = pemail
                    and gbid_rdate BETWEEN TO_DATE(psdate, 'YYYY-MM-DD') AND TO_DATE(pedate, 'YYYY-MM-DD'); 
BEGIN
    DBMS_OUTPUT.PUT_LINE('[ 기간별 조회 ]');
    DBMS_OUTPUT.PUT_LINE('기간: ' || psdate || ' ~ ' || pedate);
    
    OPEN c_gbid;
    LOOP
        FETCH c_gbid INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN c_gbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('구매희망가: ' || vprice || ', 만료일: ' || vexdate);
    END LOOP;
    IF c_gbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('구매 입찰 내역이 없습니다.');
    END IF;
    CLOSE c_gbid;
END;
-- Procedure GBID_DATE이(가) 컴파일되었습니다.
EXEC gbid_date('shiueo@naver.com', '2022-05-23', '2022-06-28');
EXEC gbid_date('shiueo@naver.com', '2022-08-23', '2022-10-28');


3. 구매희망가순 정렬
CREATE OR REPLACE PROCEDURE gbid_price_order
(
    pemail   tb_member.m_email%type
    , pnum   number  -- 0이면 오름차순, 1이면 내림차순
)
IS
    vsql      varchar2(1000);
    viamge    tb_item.i_image%type;
    vname     tb_item.i_name_eng%type;
    vsize     tb_gumaebid.gbid_size%type;
    vprice    number(12);
    vexdate   date;  -- 만료일
    vcur      SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, gbid_size, gbid_price, gbid_rdate + gbid_deadline ';
    vsql := vsql || ' FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id ';
    vsql := vsql || ' WHERE gbid_complete = 0 and m_email = :pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ 구매희망가 오름차순 정렬 ]');
        vsql := vsql || ' ORDER BY gbid_price ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 구매희망가 내림차순 정렬 ]');
        vsql := vsql || ' ORDER BY gbid_price DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('구매희망가: ' || TO_CHAR(vprice, 'FM999,999,999,999')
        || '원, 만료일: ' || TO_CHAR(vexdate, 'YYYY/MM/DD'));
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('구매 입찰 내역이 없습니다.');
    END IF;
    CLOSE vcur;
END;
-- Procedure GBID_PRICE_ORDER이(가) 컴파일되었습니다.
EXEC gbid_price_order('shiueo@naver.com', 0);
EXEC gbid_price_order('shiueo@naver.com', 1);
-- 테스트 데이터 추가
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 165000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 0, '입찰중', 4950, 3000);


4. 만료일순 정렬
CREATE OR REPLACE PROCEDURE gbid_exdate_order
(
    pemail   tb_member.m_email%type
    , pnum   number  -- 0이면 오름차순, 1이면 내림차순
)
IS
    vsql      varchar2(1000);
    viamge    tb_item.i_image%type;
    vname     tb_item.i_name_eng%type;
    vsize     tb_gumaebid.gbid_size%type;
    vprice    number(12);
    vexdate   date;  -- 만료일
    vcur      SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, gbid_size, gbid_price, gbid_rdate + gbid_deadline AS exdate';
    vsql := vsql || ' FROM tb_item i JOIN tb_gumaebid g ON i.i_id = g.i_id ';
    vsql := vsql || ' WHERE gbid_complete = 0 and m_email = :pemail
                    and gbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ 만료일 오름차순 정렬 ]');
        vsql := vsql || ' ORDER BY exdate ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 만료일 내림차순 정렬 ]');
        vsql := vsql || ' ORDER BY exdate DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('구매희망가: ' || TO_CHAR(vprice, 'FM999,999,999,999')
                            || '원, 만료일: ' || TO_CHAR(vexdate, 'YYYY/MM/DD'));
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('구매 입찰 내역이 없습니다.');
    END IF;
    CLOSE vcur;
END;
-- Procedure GBID_EXDATE_ORDER이(가) 컴파일되었습니다.
EXEC gbid_exdate_order('shiueo@naver.com', 0);
EXEC gbid_exdate_order('shiueo@naver.com', 1);
-- 테스트 데이터 삭제
DELETE FROM tb_gumaebid WHERE gbid_id = 4;


5. 입찰중 상품 상세정보
5-1. 상품 정보
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
    
    DBMS_OUTPUT.PUT_LINE('--- 구매 입찰 중 ---');
    DBMS_OUTPUT.PUT_LINE('[ 상품 정보 ]');
    DBMS_OUTPUT.PUT_LINE('주문번호: ' || pgumaeid);
    DBMS_OUTPUT.PUT_LINE(vimage || chr(10) || vmodel || ', ' || vname || ', ' || vsize);
    DBMS_OUTPUT.PUT_LINE('즉시구매가: ' || TO_CHAR(vgprice, 'FM999,999,999,999') || '원, 즉시판매가: ' 
                        || TO_CHAR(vpprice, 'FM999,999,999,999') || '원');
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('--- 구매 입찰 중 ---');
        DBMS_OUTPUT.PUT_LINE('구매 입찰 내역이 없습니다.');
END;
-- Procedure GBID_INFO1이(가) 컴파일되었습니다.
EXEC gbid_info1('shiueo@naver.com', 2);


5-2. 구매 입찰 내역
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
    
    DBMS_OUTPUT.PUT_LINE('[ 구매 입찰 내역 ]');
    DBMS_OUTPUT.PUT_LINE('구매 희망가: ' || TO_CHAR(vprice, 'FM999,999,999,999') || '원');
    DBMS_OUTPUT.PUT_LINE('검수비: 무료');
    DBMS_OUTPUT.PUT_LINE('수수료: ' || TO_CHAR(vfee, 'FM999,999,999,999') || '원');
    DBMS_OUTPUT.PUT_LINE('배송비: ' || TO_CHAR(vdelivfee, 'FM999,999,999,999') || '원');
    DBMS_OUTPUT.PUT_LINE('총 결제금액: ' || TO_CHAR(vprice + vfee + vdelivfee, 'FM999,999,999,999') || '원');
    DBMS_OUTPUT.PUT_LINE('입찰일: ' || vrdate);
    DBMS_OUTPUT.PUT_LINE('입찰마감기한: ' || vdeadline || '일 - ' || TO_CHAR(vrdate + vdeadline, 'YY/MM/DD') || '까지');
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('[ 구매 입찰 내역 ]');
        DBMS_OUTPUT.PUT_LINE('구매 입찰 내역이 없습니다.');
END;
-- Procedure GBID_INFO2이(가) 컴파일되었습니다.
EXEC gbid_info2('shiueo@naver.com', 2);


5-3. 배송 주소 및 결제 정보
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
    WHERE m_email = pemail and d_basic = 1;  -- 기본 배송지
    
    SELECT c_bank, c_id INTO vbank, vcid
    FROM tb_card
    WHERE m_email = pemail and c_pay = 1; -- 기본 결제 카드
    
    DBMS_OUTPUT.PUT_LINE('[ 배송 주소 ]');
    DBMS_OUTPUT.PUT_LINE('받는 사람: ' || REPLACE(vname, SUBSTR(vname, 2), '**'));
    DBMS_OUTPUT.PUT_LINE('휴대폰 번호: ' || REPLACE(vtel, SUBSTR(vtel, 6, 5), '***-*'));
    DBMS_OUTPUT.PUT_LINE('주소: (' || vzip || ') ' || vads || ' ' || vdetail);
    DBMS_OUTPUT.PUT_LINE('[ 결제 정보 ]');
    DBMS_OUTPUT.PUT_LINE(vbank || ' ****-****-****-' || SUBSTR(vcid, 13, 3) || '*');
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('--- 구매 입찰 중 ---');
        DBMS_OUTPUT.PUT_LINE('배송 주소 및 결제 정보가 없습니다.');
END;
-- Procedure GBID_INFO3이(가) 컴파일되었습니다.
EXEC gbid_info3('shiueo@naver.com');

-- 전체 출력
EXEC gbid_info1('shiueo@naver.com', 2);
EXEC gbid_info2('shiueo@naver.com', 2);
EXEC gbid_info3('shiueo@naver.com');


6. 입찰 내역 삭제하기
CREATE OR REPLACE PROCEDURE del_gbid
(
    pgumaeid  tb_gumaebid.gbid_id%type
)
IS
BEGIN
    DELETE FROM tb_gumaebid
    WHERE gbid_id = pgumaeid;
    DBMS_OUTPUT.PUT_LINE('입찰 내역이 삭제되었습니다.');
END;
-- Procedure GBID_INFO1이(가) 컴파일되었습니다.
EXEC del_gbid(3);
ROLLBACK;
SELECT * FROM tb_gumaebid;



< 진행중 >
-- 구매여부 1
1. 상태별 조회
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
    DBMS_OUTPUT.PUT_LINE('--- 구매 내역 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 진행 중 ]');
    DBMS_OUTPUT.PUT_LINE('[ 상태별 조회 ]');
    DBMS_OUTPUT.PUT_LINE('선택한 상태: ' || pitemstate);
    OPEN c_gbid;
    LOOP
        FETCH c_gbid INTO viamge, vname, vsize, vstate;
        EXIT WHEN c_gbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('상태: ' || vstate);
    END LOOP;
    IF c_gbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('거래 내역이 없습니다.');
    END IF;
    CLOSE c_gbid;
END;
-- Procedure GING_STATE이(가) 컴파일되었습니다.
EXEC ging_state('shiueo@naver.com', '입고대기');
-- 테스트 데이터 추가
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 165000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 1, '입고대기', 4950, 3000);
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 270, 190000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 1, '배송 중', 5700, 3000);


2. 상태순 정렬
CREATE OR REPLACE PROCEDURE ging_state_order
(
    pemail   tb_member.m_email%type
    , pnum   number  -- 0이면 오름차순, 1이면 내림차순
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
        DBMS_OUTPUT.PUT_LINE('[ 상태 오름차순 정렬 ]');
        vsql := vsql || ' ORDER BY gbid_itemstate ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 상태 내림차순 정렬 ]');
        vsql := vsql || ' ORDER BY gbid_itemstate DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vstate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('상태: ' || vstate);
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('거래 내역이 없습니다.');
    END IF;
    CLOSE vcur;
END;
-- Procedure GING_STATE_ORDER이(가) 컴파일되었습니다.
EXEC ging_state_order('shiueo@naver.com', 0);
EXEC ging_state_order('shiueo@naver.com', 1);
-- 테스트 데이터 삭제
DELETE FROM tb_gumaebid WHERE gbid_id IN (5, 6);


3. 진행중 상품 상세정보
3-1. 상품 정보
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
    
    DBMS_OUTPUT.PUT_LINE('--- 구매 진행 중 ---');
    DBMS_OUTPUT.PUT_LINE('[ 상품 정보 ]');
    DBMS_OUTPUT.PUT_LINE('주문번호: ' || pmatid);
    DBMS_OUTPUT.PUT_LINE(vimage || chr(10) || vmodel || ', ' || vname || ', ' || vsize);
    DBMS_OUTPUT.PUT_LINE('진행상황: ' || vitemstate);
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('--- 구매 진행 중 ---');
        DBMS_OUTPUT.PUT_LINE('구매 진행 중 상품이 없습니다.');
END;
-- Procedure GBID_INFO1이(가) 컴파일되었습니다.
EXEC ging_info1('hyungjs1234@naver.com', 2);
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 1, '입고대기', 1550, '한진택배', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'hyungjs1234@naver.com', 1, 240, 155000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 1, '입고대기', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2022/10/20', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 270, 160000
            , TO_DATE('2022/10/18', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 1, '발송요청', 1600, '우체국택배', '7543135431');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'hyungjs1234@naver.com', 1, 270, 160000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 1, '대기중', 4800, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 7, 5, 0, 270, 160000, TO_DATE('2022/10/18', 'YYYY/MM/DD'), TO_DATE('2022/10/22', 'YYYY/MM/DD'));

ROLLBACK;

SELECT * FROM tb_panmaebid;
SELECT * FROM tb_gumaebid;
SELECT * FROM tb_matching;
  
  
3-2. 결제 정보
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
    
    DBMS_OUTPUT.PUT_LINE('총 결제금액: ' || TO_CHAR(vprice + vfee + vdelivfee, 'FM999,999,999,999') || '원');
    DBMS_OUTPUT.PUT_LINE('검수비: 무료');
    DBMS_OUTPUT.PUT_LINE('수수료: ' || TO_CHAR(vfee, 'FM999,999,999,999') || '원');
    DBMS_OUTPUT.PUT_LINE('배송비: ' || TO_CHAR(vdelivfee, 'FM999,999,999,999') || '원');
    DBMS_OUTPUT.PUT_LINE('거래일시: ' || TO_CHAR(vmatdate, 'YY/MM/DD HH24:MI'));
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('--- 구매 진행 중 ---');
        DBMS_OUTPUT.PUT_LINE('구매 진행 중 상품이 없습니다.');
END;
-- Procedure GING_INFO2이(가) 컴파일되었습니다.
EXEC ging_info2('hyungjs1234@naver.com', 2);


< 종료 >
-- 구매여부 2
1. 구매일순(거래일순) 정렬
CREATE OR REPLACE PROCEDURE gend_matdate_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0이면 오름차순, 1이면 내림차순
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
    
    DBMS_OUTPUT.PUT_LINE('--- 구매 내역 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 종료 ]');
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ 구매일 오름차순 정렬 ]');
        vsql := vsql || ' ORDER BY mat_date ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 구매일 내림차순 정렬 ]');
        vsql := vsql || ' ORDER BY mat_date DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vmatdate, vstate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('구매일: ' || vmatdate || ', 상태: ' || vstate);
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('거래 내역이 없습니다.');
    END IF;
    CLOSE vcur;
END;
-- Procedure GEND_MATDATE_ORDER이(가) 컴파일되었습니다.
EXEC gend_matdate_order('shiueo@naver.com', 0);
EXEC gend_matdate_order('shiueo@naver.com', 1);

-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 2, '정산완료', 1550, '한진택배', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 155000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 2, '배송완료', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2022/10/20', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

ROLLBACK;


2. 종료 상품 상세정보
-- 진행중 상품 상세정보와 동일


------------------------------------빠른 실행---------------------------------------
[ 구매 내역 페이지 ]
1. 구매 입찰  -- 구매여부 0
< 조회 >
-- 전체 조회(이메일)
EXEC gbid_default('shiueo@naver.com');

-- 기간별 조회(이메일, 시작일, 종료일)
EXEC gbid_date('shiueo@naver.com', '2022-05-23', '2022-06-28');
EXEC gbid_date('shiueo@naver.com', '2022-08-23', '2023-1-11');


< 정렬 >
-- 테스트 데이터 추가
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 165000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 0, '입찰중', 4950, 3000);
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 165000
            , TO_DATE('2022/12/20', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 0, '입찰중', 4950, 3000);
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 250, 170000
            , TO_DATE('2023/01/05', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 0, '입찰중', 4950, 3000);

-- 구매희망가순 정렬(이메일, 정렬방식)
-- 0이면 오름차순, 1이면 내림차순(이하 전부 동일)
EXEC gbid_price_order('shiueo@naver.com', 0);
EXEC gbid_price_order('shiueo@naver.com', 1);

-- 만료일순 정렬(이메일, 정렬방식)
EXEC gbid_exdate_order('shiueo@naver.com', 0);
EXEC gbid_exdate_order('shiueo@naver.com', 1);

-- 테스트 데이터 삭제
DELETE FROM tb_gumaebid WHERE gbid_id >= 4;


< 입찰중 상품 상세정보 출력 >
-- 상품정보(이메일, 구매입찰 코드)
EXEC gbid_info1('shiueo@naver.com', 2);

-- 구매 입찰 내역(이메일, 구매입찰 코드)
EXEC gbid_info2('shiueo@naver.com', 2);

-- 배송 주소 및 결제 정보(이메일)
EXEC gbid_info3('shiueo@naver.com');


< 입찰 내역 삭제 >
-- 입찰 내역 삭제(구매입찰 코드) 
EXEC del_gbid(3);

-- 확인 및 롤백
ROLLBACK;
SELECT * FROM tb_gumaebid;


2. 진행중  -- 구매여부 1
-- 테스트 데이터 추가
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 165000
            , TO_DATE('2023/1/1', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 1, '입고대기', 4950, 3000);
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 270, 190000
            , TO_DATE('2023/1/8', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 1, '배송 중', 5700, 3000);


< 조회 >
-- 상태별 조회(이메일, 제품 상태)
EXEC ging_state('shiueo@naver.com', '입고대기');


< 정렬 >
-- 상태순 정렬(이메일, 정렬방식)
EXEC ging_state_order('shiueo@naver.com', 0);
EXEC ging_state_order('shiueo@naver.com', 1);

-- 테스트 데이터 삭제
DELETE FROM tb_gumaebid WHERE gbid_id IN (4, 5);
commit;

< 진행중 상품 상세정보 >
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 1, '입고대기', 1550, '한진택배', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'hyungjs1234@naver.com', 1, 240, 155000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 1, '입고대기', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2022/10/20', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 270, 160000
            , TO_DATE('2022/10/18', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 1, '발송요청', 1600, '우체국택배', '7543135431');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'hyungjs1234@naver.com', 1, 270, 160000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 1, '대기중', 4800, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 7, 5, 0, 270, 160000, TO_DATE('2022/10/18', 'YYYY/MM/DD'), TO_DATE('2022/10/22', 'YYYY/MM/DD'));

-- 확인 및 롤백
SELECT * FROM tb_panmaebid;
SELECT * FROM tb_gumaebid;
SELECT * FROM tb_matching;
ROLLBACK;
  
-- 상품 정보(이메일, 주문번호)
EXEC ging_info1('hyungjs1234@naver.com', 2);

-- 결제 정보(이메일, 주문번호)
EXEC ging_info2('hyungjs1234@naver.com', 2);


3. 종료  -- 구매여부 2
< 정렬 >
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2023/1/1', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 2, '정산완료', 1550, '한진택배', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 155000
            , TO_DATE('2023/1/5', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 2, '배송완료', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2023/1/5', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 230, 160000
            , TO_DATE('2023/1/3', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 2, '정산완료', 1550, '한진택배', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 230, 160000
            , TO_DATE('2023/1/6', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 2, '배송완료', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 230, 155000, TO_DATE('2023/1/6', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));


-- 구매일순(거래일순) 정렬(이메일, 정렬방식)
EXEC gend_matdate_order('shiueo@naver.com', 0);
EXEC gend_matdate_order('shiueo@naver.com', 1);

-- 롤백
ROLLBACK;

select * from tb_gumaebid;

< 종료 상품 상세정보 >
-- 진행중 상품 상세정보와 동일
