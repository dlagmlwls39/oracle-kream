[ 빠른배송/일반배송 구매하기 ]
-- 시퀀스
CREATE SEQUENCE i95_id INCREMENT BY 1 START WITH 2;
DROP SEQUENCE i95_id;

select * from tb_panmaebid;
select * from tb_bpanitem

------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE 빠른일반배송구매하기
(
    p_i_name_eng IN tb_item.i_name_eng%TYPE
    , p_size number
)
IS
    v_s_size    tb_size.s_size%TYPE;
    v_is_gprice varchar2(100);
    v_quick     varchar2(100);
    v_normal    varchar2(100);
    v_95quick   varchar2(100);
    vcursor     SYS_REFCURSOR;
BEGIN
    --상품정보출력
    DBMS_OUTPUT.PUT_LINE('---상품정보---');
    상품정보(p_i_name_eng);

    DBMS_OUTPUT.PUT_LINE('---사이즈 정보---');
    OPEN vcursor FOR SELECT s_size , NVL(TO_CHAR(is_gprice,'9,999,999,999'),'구매입찰')
                            FROM tb_item i JOIN tb_itemsize it ON i.i_id = it.i_id
                                            JOIN tb_size s ON it.s_id = s.s_id
                            WHERE i_name_eng = p_i_name_eng
                            ORDER BY s_size;
    LOOP
        FETCH vcursor INTO v_s_size, v_is_gprice;
        EXIT WHEN vcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_s_size  || '   ' ||  v_is_gprice);
    END LOOP;
    CLOSE vcursor;
    
    --하단(빠른배송, 일반배송, 95점상품 가격 출력)
    DBMS_OUTPUT.PUT_LINE('선택한 사이즈 : ' || p_size);
    -- 빠른배송 최저가
    SELECT TO_CHAR(MIN(pbid_price), '9,999,999,999') INTO v_quick
    FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id 
                   JOIN tb_bpanitem b ON p.pbid_id = b.pbid_id
    WHERE i_name_eng = p_i_name_eng and p.pbid_size = p_size
        and pbid_keepcheck = 1 and pbid_95check = 0 and bpi_inspect = 1;
    
    -- 일반배송 최저가
    SELECT NVL(TO_CHAR(MIN(pbid_price), '9,999,999,999'), '구매입찰') INTO v_normal
    FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id 
    WHERE i_name_eng = p_i_name_eng and pbid_keepcheck = 0 and p.pbid_size = p_size;
    
    -- 95점 상품 최저가
    SELECT TO_CHAR(MIN(pbid_price), '9,999,999,999') INTO v_95quick
    FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id 
                   JOIN tb_95item g ON p.pbid_id = g.pbid_id
    WHERE i_name_eng = p_i_name_eng and pbid_95check = 1 and i95_soldout = 0 and p.pbid_size = p_size;

    -- 빠른배송/95점 배송은 즉시구매가가 null이면 출력X, 일반배송은 '구매입찰' 출력
    IF v_quick IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('빠른배송 : ' || v_quick);
    END IF;
    DBMS_OUTPUT.PUT_LINE('일반배송 : ' || v_normal);
    IF v_95quick IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('95점 빠른배송 : ' || v_95quick);
    END IF;
END;
-- Procedure 빠른일반배송구매하기이(가) 컴파일되었습니다.
EXEC 빠른일반배송구매하기('Nike Air Force 1 ''07 Low White', 250);

-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'shiueo@naver.com', 1, null, 250, 180000
            , TO_DATE('22/10/01', 'YY/MM/DD'), 30, 0, 1, '집앞8', 0, '발송요청', 1800, null, null); 
INSERT INTO tb_bpanitem VALUES (bpi_id.nextval, 28, 1, 1, 3000);


CREATE OR REPLACE PROCEDURE 상품정보 
( 
    p_i_name_eng IN tb_item.i_name_eng%TYPE
)
IS
    v_i_image       tb_item.i_image%TYPE;
    v_i_model       tb_item.i_model%TYPE;
    v_i_name_eng    tb_item.i_name_eng%TYPE;
    v_i_name_kor    tb_item.i_name_kor%TYPE;
    v_fast_delivery nvarchar2(4);
BEGIN
    SELECT i_image, i_model, i_name_eng, i_name_kor, 
    CASE
        WHEN (SELECT count(pbid_itemstate) 
        FROM tb_panmaebid 
        WHERE i_name_eng = p_i_name_eng
        and pbid_itemstate = '입찰중') > 0 THEN
            '빠른배송'
        ELSE ''
    END 
    INTO v_i_image, v_i_model, v_i_name_eng
                        , v_i_name_kor, v_fast_delivery 
    FROM tb_item i
    WHERE i_name_eng = p_i_name_eng;

    DBMS_OUTPUT.PUT_LINE(v_i_image || chr(10) || 
     v_i_model || chr(10) || v_i_name_eng || chr(10) || 
     v_i_name_kor || chr(10) || v_fast_delivery);
END;


------------------------------------------------------------------------
[ 95점 상품 선택 ]
CREATE OR REPLACE PROCEDURE select_95
(
    p_i_name_eng    IN tb_item.i_name_eng%TYPE
    , p_size        varchar2
    , p_ex_soldout  number  -- 판매완료 상품 제외 여부 (0이면 포함, 1이면 제외)
)
IS
    v_image     tb_item.i_image%TYPE;
    v_price     varchar2(100);
    v_soldout   nvarchar2(10);
    CURSOR c_95 IS
                SELECT i_image, TO_CHAR(i95_price, 'FM999,999,999,999') || '원'
                        , DECODE(i95_soldout, 0, '판매중', 1, '판매완료')
                FROM tb_item i JOIN tb_panmaebid p ON i.i_id = p.i_id
                               JOIN tb_95item g ON p.pbid_id = g.pbid_id
                WHERE pbid_95check = 1 and i_name_eng = p_i_name_eng
                    and pbid_size = p_size;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 95점 상품 선택 페이지 ---');
    DBMS_OUTPUT.PUT_LINE('[ 상품정보 ]');
    상품정보(p_i_name_eng);
    DBMS_OUTPUT.PUT_LINE(p_size);
    
    DBMS_OUTPUT.PUT_LINE('[ 95점 상품 선택 ]');
    OPEN c_95;
    LOOP
        FETCH c_95 INTO v_image, v_price, v_soldout;
        EXIT WHEN c_95%NOTFOUND;
        IF p_ex_soldout = 0 THEN
            DBMS_OUTPUT.PUT_LINE(v_image || chr(10) || p_i_name_eng || chr(10) || '빠른배송'
                                || chr(10) || '95점 구매가: ' || v_price || chr(10) || v_soldout);
        ELSE  -- 판매완료 제외
            IF v_soldout = '판매중' THEN
                DBMS_OUTPUT.PUT_LINE('[ 판매완료 제외 ]');
                DBMS_OUTPUT.PUT_LINE(v_image || chr(10) || p_i_name_eng || chr(10) || '빠른배송'
                                || chr(10) || '95점 구매가: ' || v_price || chr(10) || v_soldout);
            END IF;
        END IF;
    END LOOP;
    CLOSE c_95;
END;
-- Procedure SELECT_95이(가) 컴파일되었습니다.
EXEC select_95('Nike Air Force 1 ''07 Low White', 250, 0);
EXEC select_95('Nike Air Force 1 ''07 Low White', 250, 1);

-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'shiueo@naver.com', 1, null, 250, 220000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, 1, '집앞6', 2, '판매완료', 2200, '한진택배', '31456797645');
INSERT INTO tb_95item VALUES (i95_id.nextval, 6, 1, 220000, 1, 'https://kream-phinf.pstatic.net/MjAyMjA5MjZfMTIz/M…8930a7e544bc42a1b97e2f615ba4ae28.jpeg?type=l_webp'
            , '오염-반경(본드 자국 등) ≥12mm', TO_DATE('2022/10/07', 'YYYY/MM/DD'));

-- 테스트 데이터 삭제
DELETE FROM tb_95item
WHERE i95_id = 2;
DELETE FROM tb_panmaebid
WHERE pbid_id = 6;

SELECT * FROM tb_panmaebid;
SELECT * FROM tb_95item;


-------------------------------빠른 실행-------------------------------------------
[ 빠른배송/일반배송 구매하기 ]
-- 빠른배송/일반배송 구매하기(상품명(영어))
EXEC 빠른일반배송구매하기('Nike Air Force 1 ''07 Low White');


[ 95점 상품 선택 ]
-- 테스트 데이터 추가
INSERT INTO tb_panmaebid VALUES (pbid_id.nextval, 'shiueo@naver.com', 1, null, 250, 220000
            , TO_DATE('2022/10/20', 'YYYY/MM/DD'), 30, 1, 1, '집앞6', 2, '판매완료', 2200, '한진택배', '31456797645');
INSERT INTO tb_95item VALUES (i95_id.nextval, 6, 1, 220000, 1, 'https://kream-phinf.pstatic.net/MjAyMjA5MjZfMTIz/M…8930a7e544bc42a1b97e2f615ba4ae28.jpeg?type=l_webp'
            , '오염-반경(본드 자국 등) ≥12mm', TO_DATE('2022/10/07', 'YYYY/MM/DD'));

-- 상품 목록 출력(상품명(영어), 사이즈, 판매완료상품 제외 여부)
-- 0이면 판매완료 상품 포함, 1이면 제외
EXEC select_95('Nike Air Force 1 ''07 Low White', 250, 0);
EXEC select_95('Nike Air Force 1 ''07 Low White', 250, 1);

-- 테스트 데이터 삭제
DELETE FROM tb_95item
WHERE i95_id = 2;
DELETE FROM tb_panmaebid
WHERE pbid_id = 6;

SELECT * FROM tb_panmaebid;
SELECT * FROM tb_95item;

