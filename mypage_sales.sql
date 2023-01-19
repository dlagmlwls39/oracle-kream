[ 판매 내역 ]
-- 시퀀스
CREATE SEQUENCE pbid_id INCREMENT BY 1 START WITH 6;
CREATE SEQUENCE gbid_id INCREMENT BY 1 START WITH 4;
CREATE SEQUENCE mat_id INCREMENT BY 1 START WITH 2;

drop SEQUENCE gbid_id;
drop SEQUENCE mat_id;

---------------------------------------------------------------------------

< 판매입찰 >
-- 보관판매 여부 0, 판매여부 0
1. 전체 조회
CREATE OR REPLACE PROCEDURE pbid_default
(
    pemail  tb_member.m_email%type
)
IS
    viamge   tb_item.i_image%type;
    vname    tb_item.i_name_eng%type;
    vsize    tb_panmaebid.pbid_size%type;
    vprice   varchar2(20);
    vexdate  varchar2(10);  -- 만료일
    CURSOR c_pbid IS
                SELECT i_image, i_name_eng, pbid_size
                         , TO_CHAR(pbid_price, 'FM999,999,999,999') || '원' gbid_price
                         , TO_CHAR(pbid_rdate + pbid_deadline, 'YYYY/MM/DD') exdate
                FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id
                WHERE pbid_keepcheck = 0 and pbid_complete = 0 and m_email = pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE;  
                    -- 기간 기본값: 최근 2개월
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 판매 내역 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 판매 입찰 ]');
    DBMS_OUTPUT.PUT_LINE('기간: ' || ADD_MONTHS(SYSDATE, -2) || ' ~ ' || SYSDATE || ' (최근 2개월)');
    OPEN c_pbid;
    LOOP
        FETCH c_pbid INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN c_pbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('판매희망가: ' || vprice || ', 만료일: ' || vexdate);
    END LOOP;
    IF c_pbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('판매 입찰 내역이 없습니다.');
    END IF;
    CLOSE c_pbid;
END;
-- Procedure PBID_DEFAULT이(가) 컴파일되었습니다.
EXEC pbid_default('lklk9803@gmail.com');


2. 기간별 조회
CREATE OR REPLACE PROCEDURE pbid_date
(
    pemail    tb_member.m_email%type
    , psdate  varchar2  -- 입력 시작일
    , pedate  varchar2  -- 입력 종료일
)
IS  
    viamge   tb_item.i_image%type;
    vname    tb_item.i_name_eng%type;
    vsize    tb_panmaebid.pbid_size%type;
    vprice   varchar2(20);
    vexdate  varchar2(10);  -- 만료일
    CURSOR c_pbid IS
                SELECT i_image, i_name_eng, pbid_size
                         , TO_CHAR(pbid_price, 'FM999,999,999,999') || '원' pbid_price
                         , TO_CHAR(pbid_rdate + pbid_deadline, 'YYYY/MM/DD') exdate
                FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id
                WHERE pbid_keepcheck = 0 and pbid_complete = 0 and m_email = pemail
                    and pbid_rdate BETWEEN TO_DATE(psdate, 'YYYY-MM-DD') AND TO_DATE(pedate, 'YYYY-MM-DD'); 
BEGIN
    DBMS_OUTPUT.PUT_LINE('[ 기간별 조회 ]');
    DBMS_OUTPUT.PUT_LINE('기간: ' || psdate || ' ~ ' || pedate);
    
    OPEN c_pbid;
    LOOP
        FETCH c_pbid INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN c_pbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('판매희망가: ' || vprice || ', 만료일: ' || vexdate);
    END LOOP;
    IF c_pbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('판매 입찰 내역이 없습니다.');
    END IF;
    CLOSE c_pbid;
END;
-- Procedure PBID_DATE이(가) 컴파일되었습니다.
EXEC pbid_date('lklk9803@gmail.com', '2022-05-23', '2022-06-28');
EXEC pbid_date('lklk9803@gmail.com', '2022-10-23', '2023-01-16');
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'lklk9803@gmail.com', 1, null, 240, 155000
            , TO_DATE('2023/01/10', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 0, '입찰중', 1550, null, null);
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'lklk9803@gmail.com', 1, null, 240, 170000
            , TO_DATE('2022/12/15', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 0, '입찰중', 1700, null, null);
          
SELECT * FROM tb_panmaebid;


3. 판매희망가순 정렬
CREATE OR REPLACE PROCEDURE pbid_price_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0이면 오름차순, 1이면 내림차순
)
IS
    vsql    varchar2(1000);
    viamge  tb_item.i_image%type;
    vname   tb_item.i_name_eng%type;
    vsize   tb_panmaebid.pbid_size%type;
    vprice  number(12);
    vexdate date;  -- 만료일
    vcur    SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, pbid_size, pbid_price, pbid_rdate + pbid_deadline ';
    vsql := vsql || ' FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id ';
    vsql := vsql || ' WHERE pbid_keepcheck = 0 and pbid_complete = 0 and m_email = :pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ 판매희망가 오름차순 정렬 ]');
        vsql := vsql || ' ORDER BY pbid_price ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 판매희망가 내림차순 정렬 ]');
        vsql := vsql || ' ORDER BY pbid_price DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vprice, vexdate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('판매희망가: ' || TO_CHAR(vprice, 'FM999,999,999,999')
                            || '원, 만료일: ' || TO_CHAR(vexdate, 'YYYY/MM/DD'));
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('판매 입찰 내역이 없습니다.');
    END IF;
    CLOSE vcur;
END;
-- Procedure PBID_PRICE_ORDER이(가) 컴파일되었습니다.
EXEC pbid_price_order('lklk9803@gmail.com', 0);
EXEC pbid_price_order('lklk9803@gmail.com', 1);


4. 만료일순 정렬
CREATE OR REPLACE PROCEDURE pbid_exdate_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0이면 오름차순, 1이면 내림차순
)
IS
    vsql    varchar2(1000);
    viamge  tb_item.i_image%type;
    vname   tb_item.i_name_eng%type;
    vsize   tb_panmaebid.pbid_size%type;
    vprice  number(12);
    vexdate date;  -- 만료일
    vcur    SYS_REFCURSOR;
BEGIN
    vsql := ' SELECT i_image, i_name_eng, pbid_size, pbid_price, pbid_rdate + pbid_deadline AS exdate ';
    vsql := vsql || ' FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id ';
    vsql := vsql || ' WHERE pbid_keepcheck = 0 and pbid_complete = 0 and m_email = :pemail
                    and pbid_rdate BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE ';
    
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
        DBMS_OUTPUT.PUT_LINE('판매희망가: ' || TO_CHAR(vprice, 'FM999,999,999,999')
                            || '원, 만료일: ' || TO_CHAR(vexdate, 'YYYY/MM/DD'));
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('판매 입찰 내역이 없습니다.');
    END IF;
    CLOSE vcur;
END;
-- Procedure PBID_EXDATE_ORDER이(가) 컴파일되었습니다.
EXEC pbid_exdate_order('lklk9803@gmail.com', 0);
EXEC pbid_exdate_order('lklk9803@gmail.com', 1);
-- 테스트 데이터 삭제
DELETE FROM tb_panmaebid WHERE pbid_id >= 6;


5. 입찰중 상품 상세정보
-- 상품 정보, 입찰 내역은 구매 내역과 동일
-- 페널티 결제 정보는 구매 내역의 카드 정보와 동일
-- 반송 주소는 구매 내역의 배송 주소와 동일
5-1. 판매 정산 계좌
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
    
    DBMS_OUTPUT.PUT_LINE('[ 판매 정산 계좌 ]');
    DBMS_OUTPUT.PUT_LINE(vbank || RPAD(' ', LENGTH(vnum), '*'));
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('[ 판매 정산 계좌 ]');
        DBMS_OUTPUT.PUT_LINE('판매 정산 계좌가 없습니다.');
END;
-- Procedure PBID_ACCOUNT이(가) 컴파일되었습니다.
EXEC pbid_account('lklk9803@gmail.com');
EXEC pbid_account('as@naver.com');  -- 예외 발생
select * from tb_account;


< 진행 중 >
-- 보관판매 여부 0, 판매여부 1
1. 상태별 조회
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
    DBMS_OUTPUT.PUT_LINE('--- 판매 내역 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 진행 중 ]');
    DBMS_OUTPUT.PUT_LINE('[ 상태별 조회 ]');
    DBMS_OUTPUT.PUT_LINE('선택한 상태: ' || pitemstate);
    OPEN c_pbid;
    LOOP
        FETCH c_pbid INTO viamge, vname, vsize, vstate;
        EXIT WHEN c_pbid%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('상태: ' || vstate);
    END LOOP;
    IF c_pbid%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('거래 내역이 없습니다.');
    END IF;
    CLOSE c_pbid;
END;
-- Procedure PING_STATE이(가) 컴파일되었습니다.
EXEC ping_state('sdjsd@naver.com', '발송요청');


2. 상태순 정렬
CREATE OR REPLACE PROCEDURE ping_state_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0이면 오름차순, 1이면 내림차순
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
        DBMS_OUTPUT.PUT_LINE('[ 상태 오름차순 정렬 ]');
        vsql := vsql || ' ORDER BY pbid_itemstate ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 상태 내림차순 정렬 ]');
        vsql := vsql || ' ORDER BY pbid_itemstate DESC ';
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
-- Procedure PING_STATE_ORDER이(가) 컴파일되었습니다.
EXEC ping_state_order('sdjsd@naver.com', 0);
EXEC ping_state_order('sdjsd@naver.com', 1);
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'sdjsd@naver.com', 1, null, 240, 150000
            , TO_DATE('2022/12/20', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 1, '발송요청', 1500, null, null);
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'sdjsd@naver.com', 1, null, 250, 160000
            , TO_DATE('2023/01/05', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 1, '입고완료', 1600, null, null);


ROLLBACK;


3. 진행중 상품 상세정보
-- 발송 정보 이외에 모두 위와 동일
3-1. 발송 정보 출력
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
    DBMS_OUTPUT.PUT_LINE('[ 발송 정보 ]');
    DBMS_OUTPUT.PUT_LINE(vcourier || ' ' || vtrackingnum);
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('발송 정보가 없습니다.');
END;
-- Procedure PING_SHIPPING이(가) 컴파일되었습니다.
EXEC ping_shipping('hyungjs1234@naver.com', 2);


3-2. 발송 정보 변경
EXEC upd_shipping(2, '우체국택배', '736132678451');

SELECT pbid_id, pbid_courier, pbid_trackingnum 
FROM tb_panmaebid
WHERE pbid_id = 2;

ROLLBACK;


< 종료 >
-- 보관판매 여부 0, 판매여부 2
1. 정산일순 정렬
CREATE OR REPLACE PROCEDURE pend_caldate_order
(
    pemail  tb_member.m_email%type
    , pnum  number  -- 0이면 오름차순, 1이면 내림차순
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
    
    DBMS_OUTPUT.PUT_LINE('--- 판매 내역 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 종료 ]');
    
    IF pnum = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[ 정산일 오름차순 정렬 ]');
        vsql := vsql || ' ORDER BY mat_caldate ASC ';
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ 정산일 내림차순 정렬 ]');
        vsql := vsql || ' ORDER BY mat_caldate DESC ';
    END IF;
    
    OPEN vcur FOR vsql USING pemail;
    LOOP
        FETCH vcur INTO viamge, vname, vsize, vcaldate, vstate;
        EXIT WHEN vcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(viamge || chr(10) || vname || ', ' || vsize);
        DBMS_OUTPUT.PUT_LINE('정산일: ' || vcaldate || ', 상태: ' || vstate);
    END LOOP;
    IF vcur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('거래 내역이 없습니다.');
    END IF;
    CLOSE vcur;
END;
-- Procedure PEND_CALDATE_ORDER이(가) 컴파일되었습니다.
EXEC pend_caldate_order('jeifh@gmail.com', 0);
EXEC pend_caldate_order('jeifh@gmail.com', 1);

-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/12/25', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 2, '정산완료', 1550, '한진택배', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 155000
            , TO_DATE('2022/12/17', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 2, '배송완료', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 18, 10, 0, 240, 155000, TO_DATE('2022/12/25', 'YYYY/MM/DD'), TO_DATE('2022/12/27', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 270, 160000
            , TO_DATE('2022/12/18', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 2, '정산완료', 1600, '우체국택배', '7543135431');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 270, 160000
            , TO_DATE('2022/12/20', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 2, '배송완료', 4800, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 19, 11, 0, 270, 160000, TO_DATE('2022/12/20', 'YYYY/MM/DD'), TO_DATE('2022/12/22', 'YYYY/MM/DD'));

SELECT * FROM tb_panmaebid;
SELECT * FROM tb_gumaebid;
SELECT * FROM tb_matching;
rollback;

2. 종료 상품 상세정보
-- 정산일 이외에 모두 위와 동일
2-1. 정산일 출력
CREATE OR REPLACE PROCEDURE pend_caldate
(
    pmat_id   tb_matching.mat_id%type  -- 주문번호
)
IS
    vcaldate  tb_matching.mat_caldate%type;
BEGIN
    SELECT mat_caldate INTO vcaldate
    FROM tb_panmaebid p JOIN tb_matching m ON p.pbid_id = m.pbid_id
    WHERE pbid_keepcheck = 0 and pbid_complete = 2 and mat_id = pmat_id;
    DBMS_OUTPUT.PUT_LINE('정산일: ' || TO_CHAR(vcaldate, 'YY/MM/DD'));
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('판매 종료 상품 정보가 없습니다.');
END;
-- Procedure PEND_CALDATE이(가) 컴파일되었습니다.
EXEC pend_caldate(8);

-- 테스트 데이터 삭제
DELETE FROM tb_panmaebid WHERE pbid_id >= 6;
DELETE FROM tb_gumaebid WHERE gbid_id >= 4;
DELETE FROM tb_matching WHERE mat_id >= 2;


-----------------------------------빠른 실행----------------------------------------
[ 판매 내역 ]
1. 판매 입찰  -- 보관판매 여부 0, 판매여부 0
< 조회 >
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'lklk9803@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 0, '입찰중', 1550, null, null);
          
SELECT * FROM tb_panmaebid;

-- 전체 조회(이메일)
EXEC pbid_default('lklk9803@gmail.com');

-- 기간별 조회(이메일, 시작일, 종료일)
EXEC pbid_date('lklk9803@gmail.com', '2022-05-23', '2022-06-28');
EXEC pbid_date('lklk9803@gmail.com', '2022-08-23', '2022-10-28');


< 정렬>
-- 판매희망가순 정렬(이메일, 정렬방식)
EXEC pbid_price_order('lklk9803@gmail.com', 0);
EXEC pbid_price_order('lklk9803@gmail.com', 1);

-- 만료일순 정렬(이메일, 정렬방식)
EXEC pbid_exdate_order('lklk9803@gmail.com', 0);
EXEC pbid_exdate_order('lklk9803@gmail.com', 1);

-- 테스트 데이터 삭제
DELETE FROM tb_panmaebid WHERE pbid_id = 6;


< 입찰중 상품 상세정보 >
-- 상품 정보, 입찰 내역은 구매 내역과 동일
-- 페널티 결제 정보는 구매 내역의 카드 정보와 동일
-- 반송 주소는 구매 내역의 배송 주소와 동일

-- 판매 정산 계좌(이메일)
EXEC pbid_account('lklk9803@gmail.com');


2. 진행중  -- 보관판매 여부 0, 판매여부 1
< 조회 >
-- 상태별 조회(이메일, 제품 상태)
EXEC ping_state('sdjsd@naver.com', '발송요청');


< 정렬 >
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'sdjsd@naver.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 1, '입고완료', 1550, null, null);

-- 상태순 정렬(이메일, 정렬방식)
EXEC ping_state_order('sdjsd@naver.com', 0);
EXEC ping_state_order('sdjsd@naver.com', 1);

-- 롤백
ROLLBACK;


< 진행중 상품 상세정보 >
-- 발송 정보 이외에 모두 위와 동일

-- 발송 정보 출력(이메일, 판매입찰 코드)
EXEC ping_shipping('hyungjs1234@naver.com', 2);

-- 발송 정보 변경(판매입찰 코드, 택배사, 운송장번호)
EXEC upd_shipping(2, '우체국택배', '736132678451');

-- 확인 및 롤백
SELECT * FROM tb_panmaebid;
ROLLBACK;


3. 종료  -- 보관판매 여부 0, 판매여부 2
< 정렬 >
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 240, 155000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 2, '정산완료', 1550, '한진택배', '31456797645');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 240, 155000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 2, '배송완료', 4650, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 6, 4, 0, 240, 155000, TO_DATE('2022/10/20', 'YYYY/MM/DD'), TO_DATE('2022/10/24', 'YYYY/MM/DD'));

INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'jeifh@gmail.com', 1, null, 270, 160000
            , TO_DATE('2022/10/18', 'YYYY/MM/DD'), 30, 0, 0, '집앞6', 2, '정산완료', 1600, '우체국택배', '7543135431');
INSERT INTO tb_gumaebid VALUES (gbid_id.nextval, 'shiueo@naver.com', 1, 270, 160000
            , TO_DATE('2022/10/10', 'YYYY/MM/DD'), 30, 1, '일반배송', '서울', 0, 2, '배송완료', 4800, 3000);
INSERT INTO tb_matching VALUES (mat_id.nextval, 1, 7, 5, 0, 270, 160000, TO_DATE('2022/10/18', 'YYYY/MM/DD'), TO_DATE('2022/10/22', 'YYYY/MM/DD'));

-- 정산일순 정렬(이메일, 정렬방식)
EXEC pend_caldate_order('jeifh@gmail.com', 0);
EXEC pend_caldate_order('jeifh@gmail.com', 1);


< 종료 상품 상세정보 >
-- 정산일 이외에 모두 위와 동일

-- 정산일 출력(주문번호)
EXEC pend_caldate(2);

-- 테스트 데이터 삭제
DELETE FROM tb_panmaebid WHERE pbid_id >= 6;
DELETE FROM tb_gumaebid WHERE gbid_id >= 4;
DELETE FROM tb_matching WHERE mat_id >= 2;