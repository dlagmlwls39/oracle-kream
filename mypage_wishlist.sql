[ 관심 상품 ]
< 관심 상품 목록 >
-- 사이즈 출력 O, 빠른배송 여부 출력 X
1. 출력
CREATE OR REPLACE PROCEDURE interest
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
    DBMS_OUTPUT.PUT_LINE('--- 관심 상품 페이지 ---');
    OPEN c_interest;
    LOOP
        FETCH c_interest INTO vi_id, vi_image, vi_brand, vi_name, vis_gprice
                                , vb_id, vb_image, vb_brand, vb_name, vb_price, vinter_size;
        EXIT WHEN c_interest%NOTFOUND;
        IF vb_id IS NULL THEN -- 일반 상품 출력
            IF vis_gprice IS NULL THEN  -- 즉시구매가 없는 경우
                DBMS_OUTPUT.PUT_LINE(vi_image || chr(10) || vi_brand || ', ' || vi_name 
                                    || ', ' || vinter_size || ', -');
            ELSE
                DBMS_OUTPUT.PUT_LINE(vi_image || chr(10) || vi_brand || ', ' || vi_name 
                                    || ', ' || vinter_size || ', ' || vis_gprice);
            END IF;
            
        ELSE  -- 브랜드 상품 출력
            DBMS_OUTPUT.PUT_LINE(vb_image || chr(10) || vb_brand || '(브랜드 배송), ' 
                                || vb_name || ', ' || vinter_size || ', ' || vb_price);
        END IF;
    END LOOP;
    IF c_interest%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('추가하신 관심 상품이 없습니다.');
    END IF;
    CLOSE c_interest;
END;
-- Procedure INTEREST이(가) 컴파일되었습니다.
EXEC interest('shiueo@naver.com');


2. 관심 상품 삭제
CREATE OR REPLACE PROCEDURE del_inter 
(
    pinter_id   tb_interest.inter_id%type  -- 관심상품 코드
)
IS
BEGIN
    DELETE FROM tb_interest
    WHERE inter_id = pinter_id;
    DBMS_OUTPUT.PUT_LINE('관심 상품이 삭제되었습니다.');
END;
-- Procedure DEL_INTER이(가) 컴파일되었습니다.
EXEC del_inter(11);

SELECT * FROM tb_interest;
ROLLBACK;


-----------------------------------빠른 실행----------------------------------------
[ 관심 상품 ]
< 관심 상품 목록 출력 >
-- 출력(이메일)
EXEC interest('shiueo@naver.com');

< 관심 상품 삭제>
-- 삭제(관심 상품 코드)
EXEC del_inter(11);

-- 확인 및 롤백
SELECT * FROM tb_interest;
ROLLBACK;