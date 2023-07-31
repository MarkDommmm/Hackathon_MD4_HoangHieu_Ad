-- 1. Cho biết họ tên sinh viên KHÔNG học học phần nào (5đ)
select sv.masv,sv.hoten from sinhvien sv
left join diemhp dhp on dhp.masv = sv.masv
 where dhp.masv is null ;
 
-- 2. Cho biết họ tên sinh viên CHƯA học học phần nào có mã 1 (5đ)
select sv.HoTen
from sinhvien sv
left join diemhp dhp on sv.MaSV = dhp.MaSV and dhp.MaHP = 1
where dhp.MaSV is null ;
 

-- 3. Cho biết Tên học phần KHÔNG có sinh viên điểm HP <5. (5đ)
select hp.MaHP, hp.TenHP 
from dmhocphan hp
left join diemhp dhp on hp.MaHP = dhp.MaHP and dhp.DiemHP < 5
where dhp.MaSV is null;

-- 4. Cho biết Họ tên sinh viên KHÔNG có học phần điểm HP<5 (5đ)
select sv.HoTen
from sinhvien sv
left join diemhp dhp on sv.MaSV = dhp.MaSV and dhp.diemhp < 5
where dhp.MaSV is null ;

-- · DẠNG CẤU TRÚC LỒNG NHAU KHÔNG KẾT NỐI
-- 5. Cho biết Tên lớp có sinh viên tên Hoa (5đ)
select distinct l.tenlop from dmlop l
join sinhvien sv on sv.malop = l.malop
where sv.hoten like '%Hoa%' ;

-- 6. Cho biết HoTen sinh viên có điểm học phần 1 là <5.
select sv.hoten from sinhvien sv
join diemhp dhp on dhp.MaSV = sv.masv
where dhp.diemhp < 5 and dhp.mahp = 1 ;

-- 7. Cho biết danh sách các học phần có số đơn vị học trình lớn hơn hoặc bằng số đơn vị học trình của học phần mã 1.
select * from dmhocphan
where  sodvht >= (select sodvht from dmhocphan where MaHP = 1);

-- · DẠNG TRUY VẤN VỚI LƯỢNG TỪ: ALL, ANY, EXISTS
-- 8. Cho biết HoTen sinh viên có DiemHP cao nhất. (ALL)
select sv.MaSV, sv.HoTen, dhp.MaHP, dhp.DiemHP
from sinhvien sv
join diemhp dhp on dhp.MaSV = sv.MaSV
where dhp.DiemHP >= all (
    select DiemHP from diemhp
);

-- 9. Cho biết MaSV, HoTen sinh viên có điểm học phần mã 1 cao nhất. (ALL)
select sv.MaSV, sv.HoTen
from sinhvien sv
join diemhp dhp on dhp.MaSV = sv.MaSV
where dhp.DiemHP >= all (
    select DiemHP from diemhp where MaHP = 1
);

-- 10. Cho biết MaSV, MaHP có điểm HP lớn hơn bất kì các điểm HP của sinh viên mã 3 (ANY).
select sv.masv, dhp.mahp from sinhvien sv
join diemhp dhp on dhp.masv = sv.masv
where dhp.diemhp > any (
select diemhp from diemhp where mahp = 3
);
-- 11. Cho biết MaSV, HoTen sinh viên ít nhất một lần học học phần nào đó. (EXISTS)
select masv, hoten from sinhvien sv
where exists (
select 1 from diemhp dhp where dhp.masv = sv.masv );

-- 12. Cho biết MaSV, HoTen sinh viên đã không học học phần nào. (EXISTS)
select MaSV, HoTen from sinhvien sv
where not exists (
    select 1 from diemhp dhp where dhp.MaSV = sv.MaSV );

-- · DẠNG TRUY VẤN VỚI CẤU TRÚC TẬP HỢP: UNION
-- 13. Cho biết MaSV đã học ít nhất một trong hai học phần có mã 1, 2.
select MaSV from diemhp where MaHP = 1
union
select MaSV from diemhp where MaHP = 2;

-- 14. Tạo thủ tục có tên KIEM_TRA_LOP cho biết HoTen sinh viên KHÔNG có điểm HP <5 ở lớp có mã chỉ định 
-- (tức là tham số truyền vào procedure là mã lớp). Phải kiểm tra MaLop chỉ định có trong danh mục hay không,
--  nếu không thì hiển thị thông báo ‘Lớp này không có trong danh mục’. Khi lớp tồn tại thì đưa ra kết quả.
-- Ví dụ gọi thủ tục: Call KIEM_TRA_LOP(‘CT12’).
delimiter //
create procedure KIEM_TRA_LOP (Malop_input varchar(20))
begin
 declare lop_count int;
    select count(*) into lop_count from dmlop
    where MaLop = Malop_input;
    if lop_count = 0 then
        select 'Lớp này không có trong danh mục' as Message;
    else
        select sv.HoTen from sinhvien sv
        join diemhp hp on sv.MaSV = hp.MaSV
        where sv.MaLop = Malop_input and hp.DiemHP < 5;
    end if;
end;
// delimiter ;
call KIEM_TRA_LOP('CT12');

-- 15. Tạo một trigger để kiểm tra tính hợp lệ của dữ liệu nhập vào bảng sinhvien là MaSV không được rỗng à
--  Nếu rỗng hiển thị thông báo ‘Mã sinh viên phải được nhập’.
delimiter //
create trigger check_MaSV
before insert on sinhvien for each row
begin
if new.masv is null or new.masv = '' then
signal sqlstate '45000' set message_text = 'Mã sinh viên phải được nhập';
end if;
end;
// delimiter ;

-- 16. Tạo một TRIGGER khi thêm một sinh viên trong bảng sinhvien ở một lớp nào đó thì cột SiSo của lớp đó trong bảng dmlop
--  (các bạn tạo thêm một cột SiSo trong bảng dmlop) tự động tăng lên 1, đảm bảo tính toàn vẹn dữ liệu khi thêm một sinh viên mới 
--  trong bảng sinhvien thì sinh viên đó phải có mã lớp trong bảng dmlop. Đảm bảo tính toàn vẹn dữ liệu khi thêm là mã lớp phải có 
--  trong bảng dmlop.

alter table dmlop add column SiSo int not null default 0;

delimiter //
create trigger check_add 
after insert on sinhvien for each row
begin 
declare count int;
 select count(*) into count from dmlop 
 where malop = new.malop;
if count = 1 then update dmlop set SiSo = SiSo + 1 where malop = new.malop ;
    end if;
end;
// delimiter ;


-- 17. Viết một function DOC_DIEM đọc điểm chữ số thập phân thành chữ  Sau đó ứng dụng để lấy ra 
-- MaSV, HoTen, MaHP, DiemHP, DOC_DIEM(DiemHP) để đọc điểm HP của sinh viên đó thành chữ
delimiter //
create function doc_diem(diemhp float) returns varchar(255) deterministic
begin
    declare docdiem varchar(255);
    declare integer_part int;
    declare decimal_part int;

    set integer_part = floor(diemhp);
    set decimal_part = round((diemhp - integer_part) * 10);

    set docdiem =
        case
            when integer_part = 10 then 'mười'
            else case integer_part
                when 9 then 'chín'
                when 8 then 'tám'
                when 7 then 'bảy'
                when 6 then 'sáu'
                when 5 then 'năm'
                when 4 then 'bốn'
                when 3 then 'ba'
                when 2 then 'hai'
                when 1 then 'một'
                else ''
            end
        end;

    if integer_part >= 0 and integer_part <= 10 then
        set docdiem = concat(docdiem, ' phẩy ');
        
        if decimal_part = 0 then
            set docdiem = concat(docdiem, 'không');
        else
            set docdiem =
                case decimal_part
                    when 9 then concat(docdiem, 'chín')
                    when 8 then concat(docdiem, 'tám')
                    when 7 then concat(docdiem, 'bảy')
                    when 6 then concat(docdiem, 'sáu')
                    when 5 then concat(docdiem, 'lăm')
                    when 4 then concat(docdiem, 'bốn')
                    when 3 then concat(docdiem, 'ba')
                    when 2 then concat(docdiem, 'hai')
                    when 1 then concat(docdiem, 'một')
                    else ''
                end;
        end if;
    end if;
    return docdiem;
end;
// delimiter ;

select
    sv.masv ,
    sv.hoten ,
    d.mahp,
    d.diemhp ,
    doc_diem(d.diemhp) 
from
    sinhvien sv
join
    diemhp d on sv.masv = d.masv;

-- 18. Tạo thủ tục: HIEN_THI_DIEM Hiển thị danh sách gồm MaSV, HoTen, MaLop, DiemHP, MaHP của những sinh viên có DiemHP nhỏ hơn
--  số chỉ định, nếu không có thì hiển thị thông báo không có sinh viên nào.
-- VD: Call HIEN_THI_DIEM(5);
delimiter //
create procedure HIEN_THI_DIEM(input float)
begin
 declare count int;
 select count(*) into count from sinhvien sv 
 join diemhp dhp on dhp.masv = sv.masv 
 where dhp.DiemHp < input ;
    if count > 0 then
        select sv.MaSV, sv.HoTen, sv.MaLop, dhp.DiemHP, dhp.MaHP
        from sinhvien sv
        join diemhp dhp on dhp.MaSV = sv.MaSV
        where dhp.DiemHP < input;
    else
        select 'Không có sinh viên nào có điểm HP nhỏ hơn ', input as DiemHP;
   end if;
end;
// delimiter  ;
call HIEN_THI_DIEM(5);

-- 19. Tạo thủ tục: HIEN_THI_MAHP hiển thị HoTen sinh viên CHƯA học học phần có mã chỉ định. Kiểm tra mã học phần chỉ định có
--  trong danh mục không. Nếu không có thì hiển thị thông báo không có học phần này.
-- Vd: Call HIEN_THI_MAHP(1);
delimiter //
create procedure HIEN_THI_MAHP (mahp_input int)
begin
  declare  count int;

  select COUNT(*) into count from diemhp dhp
where dhp.mahp = mahp_input;
  
  if count = 0 then select "Khong co sinh vien nao" as Message;
else
    select sv.hoten from sinhvien sv
    join diemhp dhp on sv.masv = dhp.masv
    where dhp.mahp =  mahp_input;
  end if;
end;
//
delimiter ;
call HIEN_THI_MAHP (1);

-- 20. Tạo thủ tục: HIEN_THI_TUOI à Hiển thị danh sách gồm: MaSV, HoTen, MaLop, NgaySinh, GioiTinh, Tuoi của sinh viên có tuổi 
-- trong khoảng chỉ định. Nếu không có thì hiển thị không có sinh viên nào.
-- VD: Call HIEN_THI_TUOI (20,30);
delimiter //
create procedure hien_thi_tuoi (input int, input2 int)
begin
    declare count int;
    select count(*) into count
    from sinhvien
    where year(now()) - year(ngaysinh) between input and input2;
    if count > 0 then
        select masv, hoten, malop, ngaysinh, gioitinh, year(now()) - year(ngaysinh) as tuoi
        from sinhvien
        where year(now()) - year(ngaysinh) between input and input2;
    else
        select 'không có sinh viên nào trong khoảng tuổi từ ' as message;
    end if;
end;
// delimiter ;
 Call HIEN_THI_TUOI (24,30);