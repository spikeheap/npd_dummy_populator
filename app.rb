require 'dotenv'
require 'faker'
require 'sequel'   
require 'securerandom'

Dotenv.load
Faker::Config.locale = 'en-GB'

DB = Sequel.connect(adapter: 'tinytds', 
                    host: 'localhost', 
                    database: 'Repository_Live', 
                    user: ENV['MSSQL_USERNAME'] || 'sa', 
                    password: ENV['MSSQL_PASSWORD'],
                    timeout: 60)

require './ks2_pupil'

class App
  def create_pupils(count: 1)
    pupils = count.times.map{ build_pupil }
    Ks2Pupil.multi_insert(pupils)
  end

  def build_pupil
    academic_year = rand(2015..2017)
    is_female = Random.new.rand(1.0) > 0.5 
    ethnicity = %i(wirt wrom woth mwbc mwba mwas moth aind apkn aban aoth bcrb bafr both chne ooth uncla).sample
    dob = Faker::Date.birthday(7, 11) # pupil between 7 and 11
    age_start = age_at(dob, Date.new(academic_year,9,1))
    local_authority_id = (201..938).to_a.sample
    estab = format('%04d', rand(9999))

    is_cla = Random.new.rand(1.0) > 0.9
    cla_months = rand(24)

    is_fsm = Random.new.rand(1.0) > 0.9

    is_refugee = Random.new.rand(1.0) > 0.9

    is_open_academy = Random.new.rand(1.0) > 0.8

    joined_school_years_ago = rand(5)

    nftype = (10..60).to_a.sample

    Ks2Pupil.new(
      acadyr: academic_year, 
      pupilid: rand(2_147_483_647),
      candno: rand(9999999),
      matchref: SecureRandom.uuid[0...11],
      dcaref: SecureRandom.uuid[0...9],
      ndcref: SecureRandom.uuid[0...9],
      npdref: SecureRandom.uuid[0...9],
      # checkref # not in datatables
      # cand_id # only 2002/2003
      upn: SecureRandom.uuid[0...13],
      surname: Faker::Name.last_name,
      forenames: "#{Faker::Name.first_name} #{Faker::Name.middle_name}",
      dob: dob,
      age_start: age_start,
      month_part: rand(11),
      yearofbirth: dob.year,
      monthofbirth: dob.month,
      examdob: dob,
      plascdob: dob,
      yeargrp: rand(17),
      actyrgrp: (['N1', 'N2', 'R'] + (1..14).to_a).sample,
      ethnic: ethnicity,
      # sourcee # not in datatables
      gender: is_female ? 'F': 'M',
      idaci: Random.new.rand(1.0),
      rawgender: Random.new.rand(1.0) > 0.5 ? 'M' : 'F',
      refugee: is_refugee ? 'Y' : 'N',
      rawla: local_authority_id,
      la: local_authority_id,
      la_9code: "#{local_authority_id}#{local_authority_id}#{local_authority_id}",
      rawestab: estab,
      estab: estab,
      laestab: "#{local_authority_id}#{estab}",
      entrydat: is_refugee ? date_rand(from: Date.new(academic_year-5,1,1).to_time) : nil,
      bestleae: rand_exam_id,
      bascleae: rand_exam_id,
      urn: rand(2_147_483_647),
      urn_ac: is_open_academy ? rand(2_147_483_647) : nil,
      open_ac: is_open_academy ? date_rand(from: Date.new(academic_year-10, rand(1..12), rand(1..20)).to_time): nil,
      toe_code: [0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 17, 18, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 52, 53, 56, 98].sample,
      nftype: nftype,
      mmsch: ((20..25).to_a + (50..52).to_a).include?(nftype) ? 1 : 0,
      mmsch2: (21..24).to_a.include?(nftype) ? 1 : 0,
      msch: (21..24).to_a.include?(nftype) ? 1 : 0,
      msch2: ((20..27).to_a + (50..53).to_a + [55]).include?(nftype) ? 1 : 0,
      amend: %i(A F R CL D IN J N NR TI TO TX Z).sample,
      amdpupil: %i(A F R CL D IN J N NR TI TO TX Z).sample,
      sourcecty: ['E', 'W', 'O'].sample,
      langsch: ['E', 'W'].sample,
      langmatta: ['C', 'E', 'M'].sample,
      langscita: ['C', 'E', 'M'].sample,
      endks: rand(2),
      # enrolsts
      preleae: rand(2010000..9389999),
      nentries: rand(1..4),
      examyear_en: academic_year,
      examyear_re: academic_year,
      examyear_gps: academic_year,
      examyear_ma: academic_year,
      examyear_sc: academic_year,
      schres: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      lares: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      natres: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      natmtdres: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      npdden_la: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      npdden_nat: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      schresta: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      laresta: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      natresta: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      natmtdresta: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      readoutcome: (%i(B T N 3 4 5 6 A L M Q S X Z F P) + [nil]).sample,
      matoutcome: (%i(B T N 2 3 4 5 6 A L M Q S X Z F P) + [nil]).sample,
      gpsoutcome: (%i(B T N 3 4 5 6 A L M Q S X Z F P) + [nil]).sample,
      readscore: rand(999),
      matscore: rand(999),
      gpsscore: rand(999),
      writtaoutcome: %i(1 2 3 4 5 6A D L M F P Z).sample,
      scitaoutcome: %i(1 2 3 4 5 6A D L M F P Z).sample,
      mattaoutcome: %i(1 2 3 4 5 6A D L M F P Z).sample,
      readtaoutcome: %i(1 2 3 4 5 6A D L M F P Z).sample,
      eligread: rand(2),
      eligreadta: rand(2),
      eligwrit: rand(2),
      eligwritta: rand(2),
      eligeng: rand(2),
      eligengta: rand(2),
      eligmat: rand(2),
      eligmatta: rand(2),
      eligengla: rand(2),
      eligreadla: rand(2),
      eligwritla: rand(2),
      eliggpsla: rand(2),
      eligwrittala: rand(2),
      eligrwmla: rand(2),
      eligmatla: rand(2),
      eligsci: rand(2),
      eligscita: rand(2),
      eligreadwrittamat: rand(2),
      valreadwrittamat: rand(2),
      eliggps: rand(2),
      valeng: rand(2),
      valengta: rand(2),
      valread: rand(2),
      valreadta: rand(2),
      writtaexp: rand(2),
      scitaexp: rand(2),
      mattaexp: rand(2),
      readtaexp: rand(2),
      writtadepth: rand(2),
      writtawts: rand(2),
      writtabexp: rand(2),
      scitabexp: rand(2),
      mattabexp: rand(2),
      readtabexp: rand(2),
      writtaad: rand(2),
      scitaad: rand(2),
      mattaad: rand(2),
      readtaad: rand(2),
      eligrwm: rand(2),
      valrwm: rand(2),
      rwmexp: rand(2),
      rwmhigh: rand(2),
      ks1average: rand(3..27),
      valwrit: rand(2),
      valwritta: rand(2),
      valmat: rand(2),
      valmatta: rand(2),
      valsci: rand(2),
      valscita: rand(2),
      valgps: rand(2),
      readexp: rand(2),
      matexp: rand(2),
      gpsexp: rand(2),
      readhigh: rand(2),
      mathigh: rand(2),
      gpshigh: rand(2),
      readat: rand(2),
      matat: rand(2),
      gpsat: rand(2),
      readlevta: rand(2),
      writlevta: rand(2),
      prreadlev: %i(A D W 1 2C 2B 2A 3 4).sample,
      prwritlev: %i(A D W 1 2C 2B 2A 3 4).sample,
      prmatlev: %i(A D W 1 2C 2B 2A 3 4).sample,
      welshtalev: ['A','D','L','N','W',1,2,3,4,5, nil].sample,
      welshlev: ['A','D','L','N','W',1,2,3,4,5, nil].sample,
      engtier: %i(35 A B F IN L M P T Y Z).sample,
      readmrk: (['A', 'IN', 'M'] + (0..50).to_a).sample,
      gpspaper1mrk: (['A', 'IN', 'M'] + (0..50).to_a).sample,
      gpspaper2mrk: (['A', 'IN', 'M'] + (0..20).to_a).sample,
      gpsmrk: (['A', 'IN', 'M'] + (0..70).to_a).sample,
      matpaper2mrk: (['A', 'IN', 'M'] + (0..35).to_a).sample,
      matpaper3mrk: (['A', 'IN', 'M'] + (0..35).to_a).sample,
      matarithmrk: (['A', 'IN', 'M'] + (0..40).to_a).sample,
      matmrk: (['A', 'IN', 'M'] + (0..110).to_a).sample,
      ks1_pseng: (%i(NOTSEN P1i P1ii P2i P2ii P3i P3ii) + [nil]).sample,
      ks1_psread: (%i(NOTSEN P4 P5 P6 P7 P8) + [nil]).sample,
      ks1_pswrite: (%i(NOTSEN P4 P5 P6 P7 P8) + [nil]).sample,
      ks1_psspeak: (%i(NOTSEN P4 P5 P6 P7 P8) + [nil]).sample,
      ks1_pslisten: (%i(NOTSEN P4 P5 P6 P7 P8) + [nil]).sample,
      ks1_psmaths: (%i(NOTSEN P1i P1ii P2i P2ii P3i P3ii) + [nil]).sample,
      ks1_psnum: (%i(NOTSEN P4 P5 P6 P7 P8) + [nil]).sample,
      ks1_psusing: (%i(NOTSEN P4 P5 P6 P7 P8) + [nil]).sample,
      ks1_psshape: (%i(NOTSEN P4 P5 P6 P7 P8) + [nil]).sample,
      engwritmrk: (['A', 'IN', 'M'] + (0..50).to_a).sample,
      enghndwrmrk: ((0..5).to_a + ['_NV']).sample,
      engspellmrk: ((0..10).to_a + ['_NV']).sample,
      engtotmrk: (['A', 'IN', 'M'] + (0..100).to_a).sample,
      engextmrk: ((0..34).to_a + ['_NV']).sample,
      readlev: ((3..6).to_a + %i(A B F IN L M N P Q S T X Y Z)).sample,
      engwritlev: ((3..6).to_a + %i(A B F IN L M N P Q S T X Y Z)).sample,
      engtalev: ((2..5).to_a + %i(A B F IN L M N P Q S T X Y Z)).sample,
      engmainlev: %i(2 3 4 5 A B D L M N Q X Z _X).sample,
      englev: ((2..5).to_a + %i(A B F IN L M N P Q S T X Y Z)).sample,
      englevta: ((1..6).to_a + %i(A D F IN L M P W Z)).sample,
      engextlev: ((1..6).to_a + %i(A D F IN L M P W Z)).sample,
      engpoints: [0, 15, 21, 27, 33, 39, 45, 51].sample,
      engfine: format('%.1f', Random.new.rand(5.5) + 2.5),
      mattier: %i(35 A B F H IN L M P T Y Z).sample,
      mattestamrk: (['A', 'IN', 'M'] + (0..40).to_a).sample,
      mattestbmrk: (['A', 'IN', 'M'] + (0..40).to_a).sample,
      matarthmrk: (['A', 'IN', 'M'] + (0..20).to_a).sample,
      mattotmrk: (['A', 'IN', 'M'] + (0..100).to_a).sample,
      matextmrk: (['_NV'] + (0..30).to_a).sample,
      mattalev: %i(1 2 3 4 5 6 A D F L M N P W Y Z IN _X).sample,
      matmainlev: %i(2 3 4 5 6 A B D L M N Q X Y Z _X).sample,
      matlev: %i(2 3 4 5 6 A H L M N Q S W X).sample,
      matlevta: %i(1 2 3 4 5 6 A D F IN L M P W Z).sample,
      matextlev: %i(6 _X).sample,
      matpoints: [0, 15, 21, 27, 33, 39, 45, 51].sample,
      matfine: format('%.1f', Random.new.rand(5.5) + 2.5),
      scitier: %i(2 35 A B D E F L M P T Y Z IN _X,).sample,
      scitestamrk: ((0..40).to_a + %i(A M _NV)).sample,
      scitestbmrk: ((0..40).to_a + %i(A M _NV)).sample,
      scitotmrk: ((0..80).to_a + %i(A M _NV)).sample,
      sciextmrk: ((0..30).to_a + %i(A M _NV)).sample,
      scitalev: ((1..6).to_a + %i(A D F L M N P W Y Z IN _X)).sample,
      scimainlev: %i(2 3 4 5 A B D L M N Q Z _X).sample,
      scilev: %i(1 2 3 4 5 A B D F L M N P Q T W).sample,
      scilevta: ((1..6).to_a + %i(A D F IN L M P W Z)).sample,
      gpslev: ((1..6).to_a + %i(A D F IN L M P W Z)).sample,
      readfine: format('%.1f', Random.new.rand(4) + 2.5),
      gpsfine: format('%.1f', Random.new.rand(4) + 2.5),
      sciextlev: %i(6 _X).sample,
      scipoints: [15, 21, 27, 33].sample,
      # scifine
      levleng: rand(2),
      levlmat: rand(2),
      levlsci: rand(2),
      levlems: rand(2),
      levlemsta: rand(2),
      levxread: rand(2),
      levxreadta: rand(2),
      levxwrit: rand(2),
      levxwritta: rand(2),
      levxeng: rand(2),
      levxengta: rand(2),
      levxmat: rand(2),
      levxmatta: rand(2),
      levxgps: rand(2),
      lev4bread: rand(2),
      lev4bmat: rand(2),
      lev4bgps: rand(2),
      levxsci: rand(2),
      levxscita: rand(2),
      levxengmat: rand(2),
      levxems: rand(2),
      levxemsta: rand(2),
      levaxread: rand(2),
      levaxreadta: rand(2),
      levaxwrit: rand(2),
      levaxwritta: rand(2),
      levaxeng: rand(2),
      levaxengta: rand(2),
      levaxmat: rand(2),
      levaxmatta: rand(2),
      levaxgps: rand(2),
      levaxengmat: rand(2),
      levaxsci: rand(2),
      levaxscita: rand(2),
      levaxems: rand(2),
      levaxemsta: rand(2),
      levbxread: rand(2),
      levbxreadta: rand(2),
      levbxwrit: rand(2),
      levbxwritta: rand(2),
      levbxeng: rand(2),
      levbxengta: rand(2),
      levbxmat: rand(2),
      levbxengmat: rand(2),
      levbxmatta: rand(2),
      levbxgps: rand(2),
      lev6read: rand(2),
      lev6mat: rand(2),
      lev6gps: rand(2),
      levxreadwrittamat: rand(2),
      levaxreadwrittamat: rand(2),
      levbxreadwrittamat: rand(2),
      lev4breadwrittamat: rand(2),
      levbxscita: rand(2),
      levbxemsta: rand(2),
      lev6readmat: rand(2),
      levadreadta: rand(2),
      levadwritta: rand(2),
      levadengta: rand(2),
      levadmatta: rand(2),
      levadscita: rand(2),
      levateng: rand(2),
      levatread: rand(2),
      levatgps: rand(2),
      levatmat: rand(2),
      lev6engta: rand(2),
      lev6matta: rand(2),
      lev6scita: rand(2),
      lev6readta: rand(2),
      lev6writta: rand(2),
      levatsci: rand(2),
      totpts: (0..99).to_a.sample,
      apsdens: rand(3),
      apsdenn: rand(3),
      apsdennmts: rand(3),
      readlevks1: rand(5),
      # readlevks2
      writlevks1: rand(5),
      # writlevks2
      englevks1: rand(5),
      englevks2: rand(7),
      mathlevks1: rand(5),
      mathlevks2: rand(7),
      progeng12: rand(-3..6),
      progread12: rand(-2..5),
      progwrit12: rand(-2..5),
      progmath12: rand(-2..5),
      englevks2ta: rand(0..8),
      mathlevks2ta: rand(0..8),
      scilevks2ta: rand(-3..6),
      progeng12ta: rand(-4..8),
      progmath12ta: rand(-4..8),
      flageng12ta: rand(2),
      flagmath12ta: rand(2),
      flag2keng12: rand(2),
      progeng12flag: rand(2),
      flag2kread12: rand(2),
      flag2kwrit12: rand(2),
      flag2kmath12: rand(2),
      progmat12flag: rand(2),
      progread12flag: rand(2),
      writtalevks2: ((0..6).to_a + [nil]).sample,
      progwritta12: ((-3..6).to_a + [nil]).sample,
      progwritta12flag: [1,2,nil].sample,
      vainput: [27, 21, 17, 15, 13, 9, 3].sample,
      vaoutput: [33, 27, 21, 17, 15, 13, 9, 3].sample,
      median: format('%.1f', Random.new.rand(34)),
      vascorep: ((0..16).to_a + (-1..-18).to_a).sample,
      incva: rand(2),
      inks12va: rand(2),
      inmlwin: rand(2),
      # cvapaps (KS1 average point score)
      # ks1aps (KS1 average point score)
      # cvaaps (KS2 average point score (fg))
      # ks2apsfg (KS2 average point score (fg))
      cvapread: %i(A D L M W X 1 2C 2B).sample,
      # ks1readps
      cvapwrit: %i(A D L M W X 1 2C 2B).sample,
      # ks1writps
      cvapmat: %i(A D L M W X 1 2C 2B).sample,
      # ks1matps
      ks1averageps: format('%.2f', Random.new.rand(26.75) + 0.25),
      ks1readps_p: format('%.2f', Random.new.rand(26.75) + 0.25),
      ks1writps_p: format('%.2f', Random.new.rand(26.75) + 0.25),
      ks1matps_p: format('%.2f', Random.new.rand(26.75) + 0.25),
      ks1_psnumps: format('%.2f', Random.new.rand(25.25) + 1.75),
      # ks1_psusingps
      # ks1_psshapeps
      # ks1_psmathsav
      # cvapred
      # cvascore
      # ks1exp
      # ealgrp
      # ks1aps2
      # ks1aps3
      ks2readps: [15, 21, 27, 33, 39].sample,
      ks2matps: [15, 21, 27, 33, 39].sample,
      ks2writtaps: [3, 9, 15, 21, 27, 33, 39].sample,
      aps: format('%.2f', Random.new.rand(36.0) + 3),
      ks2engfg: format('%.2f', Random.new.rand(36.0) + 3),
      ks2readfg: format('%.2f', Random.new.rand(36.0) + 3),
      ks2matfg: format('%.2f', Random.new.rand(36.0) + 3),
      ks2writtafg: Random.new.rand(36.0) + 3,
      vaapsscore: rand(36) + 3,
      vaengscore: rand(36) + 3,
      vamatscore: rand(36) + 3,
      vaapspred1: rand(36) + 3,
      vaapspred: rand(36) + 3,
      vaengpred1: rand(36) + 3,
      vaengpred: rand(36) + 3,
      vaopred1: rand(36) + 3,
      vaopred: rand(36) + 3,
      vaoscore: rand(36) + 3,
      vamatpred1: rand(36) + 3,
      vamatpred: rand(36) + 3,
      # vareadpred1
      vareadpred: rand(36) + 3,
      vareadscore: rand(36) + 3,
      vawrittapred1: rand(36) + 3,
      vawrittapred: rand(36) + 3,
      vawrittascore: rand(36) + 3,
      papssq: rand(36) + 3,
      pe_dev: rand(36) + 3,
      pr_dev: rand(36) + 3,
      pm_dev: rand(36) + 3,
      pseng: (%i(NOTSEN P1i P1ii p2i P2ii P3i P3ii) + [nil]).sample,
      psread: (%i(NOTSEN P4 P5 P5 P6 P7 P8) + [nil]).sample,
      pswrite: (%i(NOTSEN P4 P5 P5 P6 P7 P8) + [nil]).sample,
      psspeak: (%i(NOTSEN P4 P5 P5 P6 P7 P8) + [nil]).sample,
      pslisten: (%i(NOTSEN P4 P5 P5 P6 P7 P8) + [nil]).sample,
      psmaths: (%i(NOTSEN P4 P5 P5 P6 P7 P8) + [nil]).sample,
      psnum: (%i(NOTSEN P4 P5 P5 P6 P7 P8) + [nil]).sample,
      psusing: (%i(NOTSEN P4 P5 P5 P6 P7 P8) + [nil]).sample,
      psshape: (%i(NOTSEN P4 P5 P5 P6 P7 P8) + [nil]).sample,
      psscience: (%i(NOTSEN P1i P1ii p2i P2ii P3i P3ii P4 P5 P5 P6 P7 P8) + [nil]).sample,
      inreadprog: rand(2),
      inwritprog: rand(2),
      inmatprog: rand(2),
      # ks1average_grp
      # ks1average_grp_p
      # ks2readscore
      # ks2writscore
      # ks2matscore
      # ks2readpred
      # ks2writpred
      # ks2matpred
      # ks2readpred_p
      # ks2writpred_p
      # ks2matpred_p
      # readprogscore
      # writprogscore
      # matprogscore
      # readprogscore_p
      # writprogscore_p
      # matprogscore_p
      cla_6_months: is_cla ? (cla_months > 6 ? 1 : 0) : nil,
      cla_12_months: is_cla ? (cla_months > 12 ? 1 : 0) : nil,
      cla_pp_6_months: is_cla ? (cla_months > 6 ? 1 : 0) : 0,
      cla_pp_1_day: is_cla ? 1 : [0, 1].sample,
      fsm: is_fsm ? 1 : 0,
      fsm6: is_fsm ? 1 : [0, 1].sample,
      fsm6_p: is_fsm ? 1 : [0, 1].sample,
      fsm6_cla: (is_fsm or is_cla) ? 1 : 0,
      fsm6cla1a: (is_fsm or is_cla) ? 1 : 0,
      ks1group: (1..4).to_a.sample,
      adoptedfromcare_allyears: %i(N A G R C). sample,
      senf: %i(A P S N K E).sample,
      sentype: (%i(SPLD MLD SLD PMLD BESD SLCN HI VI MSI PD ASD OTH) + [nil]).sample,
      age: age_start,
      female: is_female ? 1 : 0,
      senps: rand(2),
      sena: rand(2),
      flang: Random.new.rand(1.0) > 0.9 ? 0 : 1,
      incareev: rand(2),
      wiri: ethnicity == 'wiri' ? 1 : 0,
      wirt: ethnicity == 'wirt' ? 1 : 0,
      wrom: ethnicity == 'wrom' ? 1 : 0,
      woth: ethnicity == 'woth' ? 1 : 0,
      mwbc: ethnicity == 'mwbc' ? 1 : 0,
      mwba: ethnicity == 'mwba' ? 1 : 0,
      mwas: ethnicity == 'mwas' ? 1 : 0,
      moth: ethnicity == 'moth' ? 1 : 0,
      aind: ethnicity == 'aind' ? 1 : 0,
      apkn: ethnicity == 'apkn' ? 1 : 0,
      aban: ethnicity == 'aban' ? 1 : 0,
      aoth: ethnicity == 'aoth' ? 1 : 0,
      bcrb: ethnicity == 'bcrb' ? 1 : 0,
      bafr: ethnicity == 'bafr' ? 1 : 0,
      both: ethnicity == 'both' ? 1 : 0,
      chne: ethnicity == 'chne' ? 1 : 0,
      ooth: ethnicity == 'ooth' ? 1 : 0,
      uncla: ethnicity == 'uncla' ? 1 : 0,
      fsmwiri: ethnicity == 'wiri' ? 1 : 0,
      fsmwirt: ethnicity == 'wirt' ? 1 : 0,
      fsmwrom: ethnicity == 'wrom' ? 1 : 0,
      fsmwoth: ethnicity == 'woth' ? 1 : 0,
      fsmmwbc: ethnicity == 'mwbc' ? 1 : 0,
      fsmmwba: ethnicity == 'mwba' ? 1 : 0,
      fsmmwas: ethnicity == 'mwas' ? 1 : 0,
      fsmmoth: ethnicity == 'moth' ? 1 : 0,
      fsmaind: ethnicity == 'aind' ? 1 : 0,
      fsmapkn: ethnicity == 'apkn' ? 1 : 0,
      fsmaban: ethnicity == 'aban' ? 1 : 0,
      fsmaoth: ethnicity == 'aoth' ? 1 : 0,
      fsmbcrb: ethnicity == 'bcrb' ? 1 : 0,
      fsmbafr: ethnicity == 'bafr' ? 1 : 0,
      fsmboth: ethnicity == 'both' ? 1 : 0,
      fsmchne: ethnicity == 'chne' ? 1 : 0,
      fsmooth: ethnicity == 'ooth' ? 1 : 0,
      fsmuncla:  ethnicity == 'uncla' ? 1 : 0,
      eal_paps: rand(2),
      eal_papssq: rand(2),
      mob1: joined_school_years_ago == 0,
      mob2: joined_school_years_ago == 1,
      mob3: joined_school_years_ago >=2 && joined_school_years_ago <=3,
      # lang (not in data tables)
      # lang1st (not in data tables)
      senelk: rand(2),
      senele: rand(2),
      senelse: rand(2),
      senelapk: rand(2),
      newmobile: joined_school_years_ago == 0,
      ppcode: Faker::Address.postcode,
      sltpilot: rand(2),
      slt_app: rand(2),
      reftest: [0, 0, 0, 0, 0, 0, 9, 2, 1].sample,
      refta: [0, 0, 0, 0, 0, 0, 0, 9, 1].sample,
      # contflag (not in data tables)
      version: ['U', 'A', 'F'].sample,
      releaseflag: 0,
      readspeccon: [0,1,2].sample,
      matspeccon: [0,1,2].sample,
      gpsspeccon: [0,1,2].sample,
      # readprogscore_p_adjusted (not in data tables)
      # writprogscore_p_adjusted (not in data tables)
      # matprogscore_p_adjusted (not in data tables)
      # ks2_psnumps (not in data tables)
      # ks2_psusingps (not in data tables)
      # ks2_psshapeps (not in data tables)
      # ks2_psmathsav (not in data tables)
      plaa: %i(N A G W C).sample,
      pcode: Faker::Address.postcode
    )
  end

  private
  def age_at(dob, date_of_measurement)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def months_between(date1, date2)
    # https://stackoverflow.com/questions/9428605/find-number-of-months-between-two-dates-in-ruby-on-rails
    (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
  end

  def rand_exam_id
    rand(2010000..9389999)
  end

  # https://stackoverflow.com/questions/4894198/how-to-generate-a-random-date-in-ruby
    def date_rand(from: 0.0, to: Time.now)
      Time.at(from + rand * (to.to_f - from.to_f)).to_date
  end
end

App.new.create_pupils(count: 500)

puts "There are now #{Ks2Pupil.count} records"
