# Source: https://www.bmf-steuerrechner.de/pruefdaten/pap2016.pdf
class LST2016
  def initialize(params)
    params.select do |k, v|
      %i(AF AJAHR ALTER1 ENTSCH F JFREIB JHINZU JRE4 JRE4ENT JVBEZ
         KRV KVZ LZZ LZZFREIB LZZHINZU PKPV PKV PVZ R RE4 SONSTB SONSTENT STERBE STKL
         VBEZ VBEZM VBEZS VBS VJAHR VKAPA VMT ZKF ZMVB).include?(k)
    end.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def output
    %i(BK BKS BKV LSTLZZ SOLZLZZ SOLZS SOLZV STS STV VKVLZZ VKVSONST).map do |var|
      [var, instance_variable_get(:"@#{var}").to_i]
    end.to_h
  end

  def LST2016
    self.MPARA
    self.MRE4JL
    @VBEZBSO = 0
    @KENNVMT = 0
    self.MRE4
    self.MRE4ABZ
    self.MBERECH
    self.MSONST
    self.MVMT

    self
  end

  def MPARA
    if @KRV < 2
      if @KRV == 0
        @BBGRV = 74_400
      else
        @BBGRV = 64_800
      end
      @RVSATZAN = 0.0935
      @TBSVORV = 0.64
    end

    @BBGKVPV = 50_850
    @KVSATZAN = @KVZ / 100.0 + 0.07
    @KVSATZAG = 0.07

    if @PVS == 1
      @PVSATZAN = 0.01675
      @PVSATZAG = 0.00675
    else
      @PVSATZAN = 0.01175
      @PVSATZAG = 0.01175
    end

    if @PVZ == 1
      @PVSATZAN = @PVSATZAN + 0.0025
    end

    @W1STKL5 = 10_070
    @W2STKL5 = 26_832
    @W3STKL5 = 203_557

    @GFB = 8652
    @SOLZFREI = 972
  end

  def MRE4JL
    if @LZZ == 1
      @ZRE4J = @RE4 / 100.0
      @ZVBEZJ = @VBEZ / 100.0
      @JLFREIB = @LZZFREIB / 100.0
      @JLHINZU = @LZZHINZU / 100.0
    elsif @LZZ == 2
      @ZRE4J = @RE4 * 12 / 100.0
      @ZVBEZJ = @VBEZ * 12 / 100.0
      @JLFREIB = @LZZFREIB * 12 / 100.0
      @JLHINZU = @LZZHINZU * 12 / 100.0
    elsif @LZZ == 3
      @ZRE4J = @RE4 * 360 / 7.0 / 100.0
      @ZVBEZJ = @VBEZ * 360.0 / 7.0 / 100.0
      @JLFREIB = @LZZFREIB * 360.0 / 7.0 / 100.0
      @JLHINZU = @LZZHINZU * 360.0 / 7.0 / 100.0
    else
      @ZRE4J = @RE4 * 360 / 100.0
      @ZVBEZJ = @VBEZ * 360.0 / 100.0
      @JLFREIB = @LZZFREIB * 360.0 / 100.0
      @JLHINZU = @LZZHINZU * 360.0 / 100.0
    end

    if @AF == 0
      @F = 1
    end
  end

  def MRE4
    if @ZVBEZJ == 0
      @FVBZ = 0
      @FVB = 0
      @FVBZSO = 0
      @FVBSO = 0
    else
      if @VJAHR < 2006
        @J = 1
      elsif @VJAHR < 2040
        @J = @VJAHR - 2004
      else
        @J = 36
      end

      if @LZZ == 1
        @VBEZB = @VBEZM * @ZMVB + @VBEZS
        @HFVB = @TAB2_J / 12.0 * @ZMVB
        @FVBZ = @TAB3_J / 12.0 * @ZMVB
      else
        @VBEZB = @VBEZM * 12 + @VBEZS
        @HFVB = @TAB2_J
        @FVBZ = @TAB3_J
      end

      @FVB = @VBEZB * @TAB1_J / 100.0
      if @FVB > @HFVB
        @FVB = @HFVB
      end
      if @FVB > @ZVBEZJ
        @FVB = @ZVBEZJ
      end
      @FVBSO = @FVB + @VBEZBSO * @TAB1_J / 100.0
      if @FVBSO > @TAB2_J
        @FVBSO = @TAB2_J
      end
      @HFVBZSO = (@VBEZB + @VBEZBSO) / 100.0 - @FVBSO
      @FVBZSO = @FVBZ + @VBEZBSO / 100.0
      if @FVBZSO > @HFVBZSO
        @FBVZSO = @HFVBZSO
      end
      if @FVBZSO > @TAB3_J
        @FVBZSO = @TAB3_J
      end
      @HFVBZ = @VBEZB / 100.0 - @FVB
      if @FVBZ > @HFVBZ
        @FVBZ = @HFVBZ
      end
    end
    self.MRE4ALTE
  end

  def MRE4ALTE
    if @ALTER1 == 0
      @ALTE = 0
    else
      if @AJAHR < 2006
        @K = 1
      else
        if @AJAHR < 2040
          @K = @AJAHR - 2004
        else
          @K = 36
        end
      end
      @BMG = @ZRE4J - @ZVBEZJ
      @ALTE = @BMG * @TAB4_K
      @HBALTE = @TAB5_K
      if @ALTE > @HBALTE
        @ALTE = @HBALTE
      end
    end
  end

  def MRE4ABZ
    @ZRE4 = @ZRE4J - @FVB - @ALTE - @JLFREIB + @JLHINZU
    if @ZRE4 < 0
      @ZRE4 = 0
    end
    @ZRE4VP = @ZRE4J
    if @KENNVMT == 2
      @ZRE4VP = @ZRE4VP - @ENTSCH / 100.0
    end
    @ZVBEZ = @ZVBEZJ - @FVB
    if @ZVBEZ < 0
      @ZVBEZ = 0
    end
  end

  def MBERECH
    self.MZTABFB
    @VFRB = (@ANP + @FVB + @FVBZ) * 100.0
    self.MLSTJAHR
    @WVFRB = (@ZVE - @GFB) * 100.0
    if @WVFRB < 0
      @WVFRB = 0
    end
    @LSTJAHR = @ST * @F
    self.UPLSTLZZ
    self.UPVKVLZZ
    if @ZKF > 0
      @ZTABFB = @ZTABFB + @KFB
      self.MRE4ABZ
      self.MLSTJAHR
      @JBMG = @ST * @F
    else
      @JBMG = @LSTJAHR
    end
    self.MSOLZ
  end

  def MSOLZ
    @SOLZFREI = @SOLZFREI * @KZTAB
    if @JBMG > @SOLZFREI
      @SOLZJ = @JBMG * 5.5 / 100.0
      @SOLZMIN = (@JBMG - @SOLZFREI) * 20.0 / 100.0
      if @SOLZMIN < @SOLZJ
        @SOLZJ = @SOLZMIN
      end
      @JW = @SOLZJ * 100.0
      self.UPANTEIL
      @SOLZLZZ = @ANTEIL1
    else
      @SOLZLZZ = 0
    end
    if @R > 0
      @JW = @JBMG * 100.0
      self.UPANTEIL
      @BK = @ANTEIL1
    else
      @BK = 0
    end
  end

  def UPVKVLZZ
    self.UPVKV
    @JW = @VKV
    self.UPANTEIL
    @VKLZZ = @ANTEIL1
  end

  def UPVKV
    if @PKV > 0
      if @VSP2 > @VSP3
        @VKV = @VSP2 * 100.0
      else
        @VKV = @VSP3 * 100.0
      end
    else
      @VKV = 0
    end
  end

  def UPLSTLZZ
    @JW = @LSTJAHR * 100.0
    self.UPANTEIL
    @LSTLZZ = @ANTEIL1
  end

  def UPANTEIL
    if @LZZ == 1
      @ANTEIL1= @JW
    elsif @LZZ == 2
      @ANTEIL1 = (@JW / 12.0).floor # Ergebnis abrunden
    elsif @LZZ == 3
      @ANTEIL1 = (@JW * 7.0 / 360).floor # Ergebnis abrunden
    else
      @ANTEIL1 = (@JW / 360.0).floor # Ergebnis abrunden
    end
  end

  def MZTABFB
    @ANP = 0
    if @ZVBEZ >= 0
      if @ZVBEZ < @FVBZ
        @FVBZ = @ZVBEZ
      end
    end
    if @STKL < 6
      if @ZVBEZ > 0
        if @ZVBEZ - @FVBZ < 102
          @ANP = @ZVBEZ - @FVBZ
        else
          @ANP = 102
        end
      end
    else
      @FVBZ = 0
      @FVBZSO = 0
    end
    if @STKL < 6
      if @ZRE4 > @ZVBEZ
        if @ZRE4 - @ZVBEZ < 1000
          @ANP = @ANP + @ZRE4 - @ZVBEZ
        else
          @ANP = @ANP + 1000
        end
      end
    end
    @KZTAB = 1
    if @STKL == 1
      @SAP = 36
      @KFB = @ZKF * 7248
    elsif @STKL == 2
      @EFA = 1908
      @SAP = 36
      @KFB = @ZKF * 7248
    elsif @STKL == 3
      @KZTAB = 2
      @SAP = 36
      @KFB = @ZKF * 7248
    elsif @STKL == 4
      @SAP = 36
      @KFB = @ZKF * 3624
    elsif @STKL == 5
      @SAP = 36
      @KFB = 0
    else
      @KFB = 0
    end
    @ZTABFB = @EFA.to_i + @ANP.to_i + @SAP.to_i + @FVBZ.to_i
  end

  def MLSTJAHR
    self.UPEVP
    if @KENNVMT != 1
      @ZVE = @ZRE4 - @ZTABFB - @VSP
      self.UPMLST
    else
      @ZVE = @ZRE4 - @ZTABFB - @VSP - @VMT / 100.0 - @VKAPA / 100.0
      if @ZVE < 0
        @ZVE = (@ZVE + @VMT / 100.0 + @VKAPA / 100.0) / 5.0
        self.UPMLST
        @ST = @ST * 5
      else
        self.UPMLST
        @STOVMT = @ST
        @ZVE = @ZVE + (@VMT + @VKAPA) / 500
        self.UPMLST
        @ST = (@ST - @STOVMT) * 5 + @STOVMT
      end
    end
  end

  def UPEVP
    if @KRV > 1
      @VSP1 = 0
    else
      if @ZRE4VP > @BBGRV
        @ZRE4VP = @BBGRV
      end
      @VSP1 = @TBSVORV * @ZRE4VP
      @VSP1 = @VSP1 * @RVSATZAN
    end
    @VSP2 = 0.12 * @ZRE4VP
    if @STKL == 3
      @VHB = 3000
    else
      @VHB = 1900
    end
    if @VSP2 > @VHB
      @VSP2 = @VHB
    end
    @VSPN = @VSP1 + @VSP2
    self.MVSP
    if @VSPN > @VSP
      @VSP = @VSPN
    end
  end

  def MVSP
    if @ZRE4VP > @BBGKVPV
      @ZRE4VP = @BBGKVPV
    end
    if @PKV > 0
      if @STKL == 6
        @VSP3 = 0
      else
        @VSP3 = @PKPV * 12.0 / 100.0
      end
      if @PKV == 2
        @VSP3 = @VSP3 - @ZRE4VP * (@KVSATZAG + @PVSATZAG)
      end
    else
      @VSP3 = @ZRE4VP * (@KVSATZAN + @PVSATZAN)
    end
    @VSP = @VSP3 + @VSP1
  end

  def UPMLST
    if @ZVE < 1
      @ZVE = 0
      @X = 0
    else
      @X = @ZVE / @KZTAB
    end
    if @STKL < 5
      self.UPTAB16
    else
      self.MST5_6
    end
  end

  def MST5_6
    @ZZX = @X
    if @ZZX > @W2STKL5
      @ZX = @W2STKL5
      self.UP5_6
      if @ZZX > @W3STKL5
        @ST = @ST + (@W3STKL5 - @W2STKL5) * 0.42
        @ST = @ST + (@ZZX - @W3STKL5) * 0.45
      else
        @ST = @ST + (@ZZX - @W2STKL5) * 0.42
      end
    else
      @ZX = @ZZX
      self.UP5_6
      if @ZZX > @W1STKL5
        @VERGL = @ST
        @ZX = @W1STKL5
        self.UP5_6
        @HOCH = @ST + (@ZZX - @W1STKL5) * 0.42
        if @HOCH < @VERGL
          @ST = @HOCH
        else
          @ST = @VERGL
        end
      end
    end
  end

  def UP5_6
    @X = @ZX * 1.25
    self.UPTAB16
    @ST1 = @ST
    @X = @ZX * 0.75
    self.UPTAB16
    @ST2 = @ST
    @DIFF = (@ST1 - @ST2) * 2
    @MIST = @ZX * 0.14
    if @MIST > @DIFF
      @ST = @MIST
    else
      @ST = @DIFF
    end
  end

  def UPTAB16
    if @X < @GFB + 1
      @ST = 0
    else
      if @X < 13_670
        @Y = (@X - @GFB) / 10_000
        @RW = @Y * 993.62
        @RW = @RW + 1_400
        @ST = @RW * @Y
      elsif @X < 53_666
        @Y = (@X - 13_669) / 10_000
        @RW = (@Y * 225.40)
        @RW = @RW + 2_397
        @RW = @RW * @Y
        @ST = @RW + 952.48
      elsif @X < 254_447
        @ST = @X * 0.42 - 8394.14
      else
        @ST = @X * 0.45 - 16_027.52
      end
      @ST = @ST * @KZTAB
    end
  end

  def MSONST
    @LZZ = 1
    if @ZMVB == 0
      @ZMVB = 12
    end
    if @SONSTB == 0
      @VKVSONST = 0
      @LSTSO = 0
      @STS = 0
      @SOLZS = 0
      @BKS = 0
    else
      self.MOSONST
      self.UPVKV
      @VKVSONST = @VKV
      @ZRE4J = (@JRE4 + @SONSTB) / 100.0
      @ZVBEZJ = (@JVBEZ + @VBS) / 100.0
      @VBEZBSO = @STERBE
      self.MRE4SONST
      self.MLSTJAHR
      @WVFRBM = (@ZVE - @GFB) * 100.0
      if @WVFRBM < 0
        @WVFRBM = 0
      end
      self.UPVKV
      @VKVSONST = @VKV - @VKVSONST
      @LSTSO = @ST * 100.0
      @STS = (@LSTSO - @LSTOSO) * @F
      if @STS < 0
        @STS = 0
      end
      @SOLZS = @STS * 5.5 / 100.0
      if @R > 0
        @BKS = @STS
      else
        @BKS = 0
      end
    end
  end

  def MRE4SONST
    self.MRE4
    @FVB = @FVBSO
    self.MRE4ABZ
    @ZRE4VP = @ZRE4VP - @JRE4ENT / 100.0 - @SONSTENT / 100.0
    @FVBZ = @FVBZSO
    self.MZTABFB
    @VFRBS2 = (@ANP + @FVB + @FVBZ) * 100.0 - @VFRBS1
  end

  def MOSONST
    @ZRE4J = @JRE4 / 100.0
    @ZVBEZJ = @JVBEZ / 100.0
    @JLFREIB = @JFREIB / 100.0
    @JLHINZU = @JHINZU / 100.0
    self.MRE4
    self.MRE4ABZ
    @ZRE4VP = @ZRE4VP - @JRE4ENT / 100.0
    self.MZTABFB
    @VFRBS1 = (@ANP + @FVB + @FVBZ) * 100.0
    self.MLSTJAHR
    @WVFRBO = (@ZVE - @GFB) * 100.0
    if @WVFRBO < 0
      @WVFRBO = 0
    end
    @LSTOSO = @ST * 100
  end

  def MVMT
    if @VKAPA < 0
      @VKAPA = 0
    end
    if @VMT + @VKAPA > 0
      if @LSTSO == 0
        self.MOSONST
        @LST1 = @LSTOSO
      else
        @LST1 = @LSTSO
      end
      @VBEZBSO = @STERBE + @VKAPA
      @ZRE4J = (@JRE4 + @SONSTB + @VMT + @VKAPA) / 100.0
      @ZVBEZJ = (@JVBEZ + @VBS + @VKAPA) / 100.0
      @KENNVMT = 2
      self.MRE4SONST
      self.MLSTJAHR
      @LST3 = @ST * 100.0
      self.MRE4ABZ
      @ZRE4VP = @ZRE4VP - @JRE4ENT / 100.0 - @SONSTENT / 100.0
      @KENNVMT = 1
      self.MLSTJAHR
      @LST2 = @ST * 100.0
      @STV = @LST2 - @LST1
      @LST3 = @LST3 - @LST1
      if @LST3 < @STV
        @STV = @LST3
      end
      if @STV < 0
        @STV = 0
      else
        @STV = @STV * @F
      end
      @SOLZV = @STV * 5.5 / 100.0
      if @R > 0
        @BKV = @STV
      else
        @BKV = 0
      end
    else
      @STV = 0
      @SOLZV = 0
      @BKV = 0
    end
  end
end