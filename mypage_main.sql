[ 마이페이지 ]
< 회원 정보 >
CREATE OR REPLACE PROCEDURE member_info
(
    pemail  tb_member.m_email%type
)
IS
    vimage  tb_member.m_image%type;
    vname   tb_member.m_name%type;
    vemail  tb_member.m_email%type;
    vpoint  tb_member.m_point%type;
BEGIN
    vemail := RPAD(SUBSTR(pemail, 1, 1), INSTR(pemail, '@') - 2, '*')
        || SUBSTR(pemail, INSTR(pemail, '@') - 1);
    
    SELECT m_image, m_name, m_point INTO vimage, vname, vpoint
    FROM tb_member
    WHERE m_email = pemail;
    
    DBMS_OUTPUT.PUT_LINE('---- 마이 페이지 ---- ');
    DBMS_OUTPUT.PUT_LINE('[ 회원 정보 ]');        
    DBMS_OUTPUT.PUT_LINE(vimage || chr(10) || vname || ', ' || vemail || ', ' || vpoint || 'P');
END;
-- Procedure MEMBER_INFO이(가) 컴파일되었습니다.
EXEC member_info('jeifh@gmail.com');


< 보관 판매 내역 >
1. 거래 내역 수량 출력
CREATE OR REPLACE PROCEDURE member_bp
(
    pemail  tb_member.m_email%type
)
IS
    vbpsendreq  tb_amount.am_bpsendreq%type;
    vbpwait     tb_amount.am_bpwait%type;
    vbping      tb_amount.am_bping%type;
    vbpcalcompl tb_amount.am_bpcalcompl%type;
BEGIN
    SELECT am_bpsendreq, am_bpwait, am_bping, am_bpcalcompl
        INTO vbpsendreq, vbpwait, vbping, vbpcalcompl
    FROM tb_amount
    WHERE m_email = pemail;

    DBMS_OUTPUT.PUT_LINE('[ 보관 판매 내역 ]');
    DBMS_OUTPUT.PUT_LINE('발송요청 : ' || vbpsendreq);
    DBMS_OUTPUT.PUT_LINE('판매대기 : ' || vbpwait);
    DBMS_OUTPUT.PUT_LINE('판매중 : ' || vbping);
    DBMS_OUTPUT.PUT_LINE('정산완료 : ' || vbpcalcompl);
END;
-- Procedure MEMBER_BP이(가) 컴파일되었습니다.
EXEC member_bp('hyungjs1234@naver.com');


< 구매 내역 >
1. 거래 내역 수량 출력
CREATE OR REPLACE PROCEDURE member_gu
(
    pemail  tb_member.m_email%type
)
IS
    vgulog     tb_amount.am_gulog%type;
    vgubid     tb_amount.am_gubid%type;
    vguing     tb_amount.am_guing%type;
    vgucompl   tb_amount.am_gucompl%type;
BEGIN
    SELECT am_gulog, am_gubid, am_guing, am_gucompl
        INTO vgulog, vgubid, vguing, vgucompl
    FROM tb_amount
    WHERE m_email = pemail;
    
    DBMS_OUTPUT.PUT_LINE('[ 구매 내역 ]');
    DBMS_OUTPUT.PUT_LINE('전체 : ' || vgulog);
    DBMS_OUTPUT.PUT_LINE('입찰중 : ' || vgubid);
    DBMS_OUTPUT.PUT_LINE('진행중 : ' || vguing);
    DBMS_OUTPUT.PUT_LINE('종료 : ' || vgucompl);
END;
-- Procedure MEMBER_GU이(가) 컴파일되었습니다.
EXEC member_gu('hyungjs1234@naver.com');


< 판매 내역 >
1. 거래 내역 수량 출력
CREATE OR REPLACE PROCEDURE member_pan
(
    pemail  tb_member.m_email%type
)
IS
    vpanlog     tb_amount.am_panlog%type;
    vpanbid     tb_amount.am_panbid%type;
    vpaning     tb_amount.am_paning%type;
    vpancompl   tb_amount.am_pancompl%type;
BEGIN
    SELECT am_panlog, am_panbid, am_paning, am_pancompl
        INTO vpanlog, vpanbid, vpaning, vpancompl
    FROM tb_amount
    WHERE m_email = pemail;
    
    DBMS_OUTPUT.PUT_LINE('[ 판매 내역 ]');
    DBMS_OUTPUT.PUT_LINE('전체 : ' || vpanlog);
    DBMS_OUTPUT.PUT_LINE('입찰중 : ' || vpanbid);
    DBMS_OUTPUT.PUT_LINE('진행중 : ' || vpaning);
    DBMS_OUTPUT.PUT_LINE('종료 : ' || vpancompl);
END;
-- Procedure MEMBER_PAN이(가) 컴파일되었습니다.
EXEC member_pan('hyungjs1234@naver.com');


< 관심 상품 >
1. 관심 상품 목록 출력
-- 사이즈 출력 X, 빠른배송 여부 출력 O
CREATE OR REPLACE PROCEDURE member_inter
(
    pemail  tb_member.m_email%type
)
IS
    vi_id       tb_item.i_id%type;
    vi_image    tb_item.i_image%type;
    vi_brand    tb_item.i_brand%type;
    vi_name     tb_item.i_name_eng%type;
    vis_gprice  tb_itemsize.is_gprice%type;
    vb_id       tb_branditem.b_id%type;
    vb_image    tb_branditem.b_image%type;
    vb_brand    tb_branditem.b_brand%type;
    vb_name     tb_branditem.b_name_eng%type;
    vb_price    tb_branditem.b_price%type;
    vinter_size tb_interest.inter_size%type;
    visquick    number;
    -- 상품 커서
    CURSOR c_interest IS
                        SELECT i_id, i_image, i_brand, i_name_eng, is_gprice
                                , b_id, b_image, b_brand, b_name_eng, b_price
                                , inter_size
                        FROM (
                            SELECT inter_id, a.i_id, i_image, i_brand, i_name_eng
                                    , a.b_id, b_image, b_brand, b_name_eng, b_price, a.inter_size
                            FROM tb_interest a LEFT JOIN tb_item b ON a.i_id = b.i_id
                                               LEFT JOIN tb_branditem c ON a.b_id = c.b_id
                            WHERE a.m_email = pemail
                        )t1 JOIN (
                            SELECT s_size, is_gprice
                            FROM tb_size a LEFT JOIN tb_itemsize b ON a.s_id = b.s_id
                        )t2 ON t1.inter_size = t2.s_size
                        ORDER BY inter_id DESC;  -- 최근등록순 정렬
BEGIN
    SELECT COUNT(*) INTO visquick  -- 0보다 크면 빠른배송
    FROM (
        SELECT a.i_id, a.inter_size
        FROM tb_interest a LEFT JOIN tb_item b ON a.i_id = b.i_id
        WHERE a.m_email = pemail
    )t1 JOIN (
        SELECT s_size
        FROM tb_size a LEFT JOIN tb_itemsize b
        ON a.s_id = b.s_id
    )t2 ON t1.inter_size = t2.s_size
    JOIN tb_panmaebid a ON t1.i_id = a.i_id
    JOIN tb_bpanitem b ON a.pbid_id = b.pbid_id
    JOIN tb_95item c ON a.pbid_id = c.pbid_id
    WHERE (pbid_keepcheck = 1 and bpi_inspect = 1) or (pbid_95check = 1 and i95_soldout = 0);
    
    DBMS_OUTPUT.PUT_LINE('[ 관심 상품 ]');
    
    OPEN c_interest;
    LOOP
        FETCH c_interest INTO vi_id, vi_image, vi_brand, vi_name, vis_gprice
                            , vb_id, vb_image, vb_brand, vb_name, vb_price, vinter_size;
        EXIT WHEN c_interest%NOTFOUND;
        
        IF vb_id IS NULL THEN -- 일반 상품 출력
            IF vis_gprice IS NULL THEN  -- 즉시구매가 없는 경우
                DBMS_OUTPUT.PUT_LINE(vi_image || chr(10) || vi_brand || ', ' || vi_name || ', -' || chr(10));
            ELSE
                IF visquick > 0 THEN  -- 빠른배송인 경우
                    DBMS_OUTPUT.PUT_LINE(vi_image || chr(10) || vi_brand || ', ' 
                                        || vi_name || ', 빠른배송, ' || vis_gprice || chr(10));
                ELSE  -- 일반배송인 경우
                    DBMS_OUTPUT.PUT_LINE(vi_image || chr(10) || vi_brand || ', ' 
                                        || vi_name || ', ' || vis_gprice || chr(10));
                END IF;
            END IF;
    
        ELSE  -- 브랜드 상품 출력
            DBMS_OUTPUT.PUT_LINE(vb_image || chr(10) || vb_brand || ', ' || vb_name
                                || ', 브랜드배송, ' || vb_price || chr(10));
        END IF;
    END LOOP;
    IF c_interest%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('추가하신 관심 상품이 없습니다.');
    END IF;
    CLOSE c_interest;
END;
-- Procedure MEMBER_INTER이(가) 컴파일되었습니다.
EXEC member_inter('shiueo@naver.com');


< 거래 내역 수량 변경 >
1. 정산 완료(거래 종료)
CREATE OR REPLACE PROCEDURE complete_cal
(
    ppbid_id        tb_panmaebid.pbid_id%type  -- 판매 입찰 코드
    , ppbid_state   tb_panmaebid.pbid_itemstate%type  -- 변경할 제품 상태
    , pgbid_id      tb_gumaebid.gbid_id%type  -- 구매 입찰 코드
    , pgbid_state   tb_gumaebid.gbid_itemstate%type  -- 변경할 제품 상태
)
IS
BEGIN
    IF ppbid_id IS NOT NULL THEN  -- 판매 상품의 제품 상태 변경
        UPDATE tb_panmaebid
        SET pbid_itemstate = ppbid_state, pbid_complete = 2
        WHERE pbid_id = ppbid_id;
    END IF;
    
    IF pgbid_id IS NOT NULL THEN  -- 구매 상품의 제품 상태 변경
        UPDATE tb_gumaebid
        SET gbid_itemstate = pgbid_state, gbid_complete = 2
        WHERE gbid_id = pgbid_id;
    END IF;
END;
-- Procedure COMPLETE_CAL이(가) 컴파일되었습니다.


2. 판매 내역 수량 변경(일반 판매/보관 판매)
CREATE OR REPLACE PROCEDURE upd_amount_pan
(
    ppbid_id    tb_panmaebid.pbid_id%type
)
IS 
    vpanbid     number;
    vpaning     number;
    vpancompl   number;
    vpanlog     number;
    vbpsendreq  number;
    vbpwait     number;
    vbping      number;
    vbpcalcompl number;
    vemail      tb_member.m_email%type;
    vkeepcheck  tb_panmaebid.pbid_keepcheck%type;
BEGIN
    SELECT m_email, pbid_keepcheck INTO vemail, vkeepcheck
    FROM tb_panmaebid
    WHERE pbid_id = ppbid_id;
    
    IF vkeepcheck = 0 THEN  -- 일반 판매 상품
        SELECT * INTO vpanbid, vpaning, vpancompl
        FROM (SELECT pbid_complete FROM tb_panmaebid WHERE m_email = vemail)
        PIVOT (COUNT(pbid_complete) FOR pbid_complete IN (0, 1, 2));
        
        vpanlog := vpanbid + vpaning + vpancompl;
        
        UPDATE tb_amount 
        SET am_panlog = vpanlog, am_panbid = vpanbid, am_paning = vpaning, am_pancompl = vpancompl
        WHERE m_email = vemail;
        
    ELSE  -- 보관 판매 상품
        SELECT * INTO vbpsendreq, vbpwait, vbping, vbpcalcompl
        FROM (SELECT pbid_itemstate FROM tb_panmaebid WHERE m_email = vemail)
        PIVOT (COUNT(pbid_itemstate) FOR pbid_itemstate IN ('발송요청', '판매대기', '판매중', '정산완료'));
        
        UPDATE tb_amount 
        SET am_bpsendreq = vbpsendreq, am_bpwait = vbpwait, am_bping = vbping, am_bpcalcompl = vbpcalcompl
        WHERE m_email = vemail;
    END IF;
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('판매 입찰 코드를 잘못 입력하였습니다.');
END;
-- Procedure UPD_AMOUNT_PAN이(가) 컴파일되었습니다.


3. 구매 내역 수량 변경
CREATE OR REPLACE PROCEDURE upd_amount_gu
(
    pgbid_id  tb_gumaebid.gbid_id%type
)
IS 
    vgubid    number;
    vguing    number;
    vgucompl  number;
    vgulog    number;
    vemail    tb_member.m_email%type;
BEGIN
    SELECT m_email INTO vemail
    FROM tb_gumaebid
    WHERE gbid_id = pgbid_id;
    
    SELECT * INTO vgubid, vguing, vgucompl
    FROM (SELECT gbid_complete FROM tb_gumaebid WHERE m_email = vemail)
    PIVOT (COUNT(gbid_complete) FOR gbid_complete IN (0, 1, 2));
    
    vgulog := vgubid + vguing + vgucompl;
        
    UPDATE tb_amount 
    SET am_gulog = vgulog, am_gubid = vgubid, am_guing = vguing, am_gucompl = vgucompl
    WHERE m_email = vemail;
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('구매 입찰 코드를 잘못 입력하였습니다.');
END;
-- Procedure UPD_AMOUNT_GU이(가) 컴파일되었습니다.

-- 1) 테스트 데이터 추가
INSERT INTO tb_gumaebid VALUES(gbid_id, 'shiueo@naver.com', 1, 250, 260000
            , TO_DATE('22/09/21', 'YY/MM/DD'), 30, 0, '빠른배송', '서울', 0, 1, '배송중', 7800, 5000);

-- 2) 프로시저 실행
EXEC complete_cal(2, '정산완료', 4, '배송완료');  -- 거래 종료, 제품 상태 변경
EXEC upd_amount_pan(2);  -- 판매 내역 수량 변경
EXEC upd_amount_gu(4);  -- 구매 내역 수량 변경

-- 3) 확인
SELECT * FROM tb_panmaebid;
SELECT * FROM tb_gumaebid;
SELECT * FROM tb_amount;
ROLLBACK;

-- 4) 테스트 데이터 롤백
DELETE FROM tb_gumaebid WHERE gbid_id = 4;
UPDATE tb_panmaebid
SET pbid_itemstate = '판매중', pbid_complete = 1
WHERE pbid_id = 2;
COMMIT;



---------------------------------빠른 실행-------------------------------------
[ 마이페이지 ]
< 화면 출력 >
-- 회원 정보 (이메일)
EXEC member_info('hyungjs1234@naver.com');

-- 보관 판매 거래 내역 수량 (이메일)
EXEC member_bp('hyungjs1234@naver.com');

-- 구매 거래 내역 수량 (이메일)
EXEC member_gu('hyungjs1234@naver.com');
EXEC member_gu('shiueo@naver.com');

-- 판매 거래 내역 수량 (이메일)
EXEC member_pan('hyungjs1234@naver.com');
EXEC member_pan('shiueo@naver.com');

-- 관심 상품 목록 (이메일)
EXEC member_inter('shiueo@naver.com');


< 정산 완료(거래 종료) 및 거래 내역 수량 갱신 >
1) 테스트 데이터 추가
INSERT INTO tb_gumaebid VALUES(gbid_id, 'shiueo@naver.com', 1, 250, 260000
            , TO_DATE('22/09/21', 'YY/MM/DD'), 30, 0, '빠른배송', '서울', 0, 1, '배송중', 7800, 5000);

2) 프로시저 실행
-- 정산 완료(판매입찰 코드, 변경할 판매 상품 상태, 구매입찰 코드, 변경할 구매 상품 상태)
EXEC end_deal(2, '정산완료', 4, '배송완료');

-- 판매 내역 수량 갱신(판매입찰 코드)
EXEC upd_amount_pan(2);

-- 구매 내역 수량 갱신(구매입찰 코드)  
EXEC upd_amount_gu(4);

3) 확인
SELECT * FROM tb_panmaebid;
SELECT * FROM tb_gumaebid;
SELECT * FROM tb_amount;
ROLLBACK;

4) 테스트 데이터 롤백
DELETE FROM tb_gumaebid WHERE gbid_id = 4;
UPDATE tb_panmaebid
SET pbid_itemstate = '판매중', pbid_complete = 1
WHERE pbid_id = 2;
COMMIT;

