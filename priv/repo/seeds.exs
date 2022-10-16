# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Myflightmap.Repo.insert!(%Myflightmap.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias Myflightmap.Repo
alias Myflightmap.Transport.{AircraftType, Airline, Airport}

airlines = [
  %Airline{
    iata_code: "LH",
    icao_code: "DLH",
    country: "DE",
    commenced_on: ~D[1953-01-06],
    name: "Lufthansa",
    alliance: "staralliance"
  },
  %Airline{
    iata_code: "SR",
    icao_code: "SWR",
    country: "CH",
    commenced_on: ~D[1931-03-26],
    name: "Swissair",
    ceased_on: ~D[2002-03-31]
  },
  %Airline{
    iata_code: "LX",
    icao_code: "CRX",
    country: "CH",
    commenced_on: ~D[1978-11-18],
    name: "Crossair",
    ceased_on: ~D[2002-03-31]
  },
  %Airline{
    iata_code: "LX",
    icao_code: "SWR",
    country: "CH",
    commenced_on: ~D[2002-03-31],
    name: "Swiss International Air Lines",
    alliance: "staralliance"
  },
  %Airline{
    iata_code: "SK",
    icao_code: "SAS",
    country: "SE",
    commenced_on: ~D[1946-08-01],
    name: "SAS Scandinavian Airlines",
    alliance: "staralliance"
  },
  %Airline{
    iata_code: "KL",
    icao_code: "KLM",
    country: "NL",
    commenced_on: ~D[1919-08-07],
    name: "KLM Royal Dutch Airlines",
    alliance: "skyteam"
  },
  %Airline{
    iata_code: "SQ",
    icao_code: "SIA",
    country: "SG",
    commenced_on: ~D[1972-08-01],
    name: "Singapore Airlines",
    alliance: "skyteam"
  },
  %Airline{
    iata_code: "QF",
    icao_code: "QFA",
    country: "AU",
    commenced_on: ~D[1921-03-01],
    name: "Qantas",
    alliance: "oneworld"
  }
]

for airline <- airlines do
  if nil == Myflightmap.Repo.get_by(Airline, Map.take(airline, [:iata_code, :name])) do
    {:ok, _record} =
      airline
      |> Map.from_struct()
      |> Myflightmap.Transport.create_airline()
  else
    IO.puts("Airline #{airline.name} already exists")
  end
end

airports = [
  %Airport{
    iata_code: "SIN",
    icao_code: "WSSS",
    country: "SG",
    coordinates: {1.359167, 103.989444},
    timezone: "Asia/Singapore",
    city: "Singapore",
    common_name: "Singapore Changi"
  },
  %Airport{
    iata_code: "HND",
    icao_code: "RJTT",
    country: "JP",
    metro_code: "TYO",
    coordinates: {35.553333, 139.781111},
    timezone: "Asia/Tokyo",
    city: "Tokyo",
    common_name: "Tokyo Haneda"
  },
  %Airport{
    iata_code: "NRT",
    icao_code: "RJAA",
    country: "JP",
    metro_code: "TYO",
    coordinates: {35.765278, 140.385556},
    timezone: "Asia/Tokyo",
    city: "Tokyo",
    common_name: "Tokyo Narita"
  },
  %Airport{
    iata_code: "HAM",
    icao_code: "EDDH",
    country: "DE",
    city: "Hamburg",
    coordinates: {53.630278, 9.991111},
    timezone: "Europe/Berlin",
    common_name: "Hamburg Airport"
  },
  %Airport{
    iata_code: "BKK",
    icao_code: "VTBS",
    country: "TH",
    metro_code: "BKK",
    coordinates: {13.6925, 100.75},
    timezone: "Asia/Bangkok",
    city: "Bangkok",
    common_name: "Bangkok Suvarnabhumi"
  },
  %Airport{
    iata_code: "DMK",
    icao_code: "VTBD",
    country: "TH",
    metro_code: "BKK",
    coordinates: {13.9125, 100.606667},
    timezone: "Asia/Bangkok",
    city: "Bangkok",
    common_name: "Bangkok Don Mueang"
  },
  %Airport{
    iata_code: "LHR",
    icao_code: "EGLL",
    country: "GB",
    metro_code: "LON",
    coordinates: {51.4775, -0.461389},
    timezone: "Europe/London",
    city: "London",
    common_name: "London Heathrow"
  },
  %Airport{
    iata_code: "LGW",
    icao_code: "EGKK",
    country: "GB",
    metro_code: "LON",
    coordinates: {51.148056, -0.190278},
    timezone: "Europe/London",
    city: "London",
    common_name: "London Gatwick"
  },
  %Airport{
    iata_code: "HKG",
    icao_code: "VHHH",
    country: "HK",
    coordinates: {22.32861, 114.194167},
    timezone: "Asia/Hong_Kong",
    city: "Hong Kong",
    common_name: "Hong Kong Kai Tak",
    opened_on: ~D[1925-01-01],
    closed_on: ~D[1998-07-06]
  },
  %Airport{
    iata_code: "HKG",
    icao_code: "VHHH",
    country: "HK",
    coordinates: {22.308889, 113.91444},
    timezone: "Asia/Hong_Kong",
    city: "Hong Kong",
    common_name: "Hong Kong International",
    opened_on: ~D[1998-07-06]
  },
  %Airport{
    iata_code: "BOS",
    icao_code: "KBOS",
    country: "US",
    coordinates: {42.363056, -71.006389},
    timezone: "America/New_York",
    city: "Boston",
    common_name: "Boston Logan",
    opened_on: ~D[1923-09-08]
  },
  %Airport{
    iata_code: "PER",
    icao_code: "YPPH",
    country: "AU",
    coordinates: {-31.940278, 115.966944},
    timezone: "Australia/Perth",
    city: "Perth",
    common_name: "Perth Airport"
  }
]

OpenFlights.get_airports()
|> Stream.filter(fn ap -> ap[:iata_code] && ap[:timezone] end)
|> Enum.each(fn airport ->
  if nil == Myflightmap.Repo.get_by(Airport, iata_code: airport.iata_code) do
    case Myflightmap.Transport.create_airport(airport) do
      {:ok, _record} ->
        IO.puts("Created #{airport.iata_code}")

      {:error, changeset} ->
        IO.warn("Failed to create #{airport.iata_code}")
        IO.inspect(:stderr, changeset, label: "Changeset dump")
    end
  else
    IO.puts("Airport #{airport.iata_code} already exists")
  end
end)

aircraft_data = ~s"""
A124	A4F	Antonov AN-124 Ruslan
A140	A40	Antonov AN-140
A148	A81	Antonov An-148
A158	A58	Antonov An-158
A19N	32D	Airbus A319neo
A20N	32A	Airbus A320neo
A21N	32B	Airbus A321neo
A225	A25	Antonov An-225 Mriya
A30B	AB3	Airbus A300B1
A30B	AB4	Airbus A300B2, A300B4, and A300C4
A306	AB6	Airbus A300-600
A310	310	Airbus A310
A318	318	Airbus A318
A319	319	Airbus A319
A320	320	Airbus A320
A321	321	Airbus A321
A332	332	Airbus A330-200
A333	333	Airbus A330-300
A338	338	Airbus A330-800neo
A339	339	Airbus A330-900neo
A342	342	Airbus A340-200
A343	343	Airbus A340-300
A345	345	Airbus A340-500
A346	346	Airbus A340-600
A359	359	Airbus A350-900
A35K	351	Airbus A350-1000
A388	388	Airbus A380-800
A748	HS7	Hawker Siddeley HS 748
AC68	ACP	Gulfstream/Rockwell (Aero) Commander
AC90	ACT	Gulfstream/Rockwell (Aero) Turbo Commander
AN12	ANF	Antonov AN-12
AN24	AN4	Antonov AN-24
AN26	A26	Antonov AN-26
AN28	A28	Antonov AN-28
AN30	A30	Antonov AN-30
AN32	A32	Antonov AN-32
AN72	AN7	Antonov AN-72 / AN-74
AP22		Aeroprakt A-22 Foxbat / A-22 Valor / A-22 Vision
AT43	AT4	Aerospatiale/Alenia ATR 42-300 / 320
AT45	AT5	Aerospatiale/Alenia ATR 42-500
AT46	ATR	Aerospatiale/Alenia ATR 42-600
AT72	AT7	Aerospatiale/Alenia ATR 72
AT73	ATR	Aerospatiale/Alenia ATR 72-200 series
AT75	ATR	Aerospatiale/Alenia ATR 72-500
AT76	ATR	Aerospatiale/Alenia ATR 72-600
ATL	ATL	Robin ATL
ATP	ATP	British Aerospace ATP
B190	BEH	Beechcraft 1900
B212	BH2	Bell 212
B412	BH2	Bell 412
B429	BH2	Bell 429
B37M	7M7	Boeing 737 MAX 7
B38M	7M8	Boeing 737 MAX 8
B39M	7M9	Boeing 737 MAX 9
B3JM	7MJ	Boeing 737 MAX 10
B461	141	BAe 146-100
B462	142	BAe 146-200
B463	143	BAe 146-300
B703	703	Boeing 707
B712	717	Boeing 717
B720	B72	Boeing 720B
B721	721	Boeing 727-100
B722	722	Boeing 727-200
B731	731	Boeing 737-100
B732	732	Boeing 737-200
B733	733	Boeing 737-300
B734	734	Boeing 737-400
B735	735	Boeing 737-500
B736	736	Boeing 737-600
B737	73G	Boeing 737-700
B738	738	Boeing 737-800
B739	739	Boeing 737-900
B741	741	Boeing 747-100
B742	742	Boeing 747-200
B743	743	Boeing 747-300
B744	744	Boeing 747-400
B748	748	Boeing 747-8
B74R	74R	Boeing 747SR
B74S	74L	Boeing 747SP
B752	752	Boeing 757-200
B753	753	Boeing 757-300
B762	762	Boeing 767-200
B763	763	Boeing 767-300
B764	764	Boeing 767-400
B772	772	Boeing 777-200 / Boeing 777-200ER
B77L	77L	Boeing 777-200LR / Boeing 777F
B773	773	Boeing 777-300
B77W	77W	Boeing 777-300ER
B778		Boeing 777-8
B779		Boeing 777-9
B788	788	Boeing 787-8
B789	789	Boeing 787-9
B78X	78J	Boeing 787-10
BA11	B11	British Aerospace (BAC) One Eleven
BCS1	CS1	Airbus A220-100
BCS3	CS3	Airbus A220-300
BE55		Beechcraft Baron / 55 Baron
BE58		Beechcraft Baron / 58 Baron
BELF	SHB	Shorts SC-5 Belfast
BER2		Beriev Be-200 Altair
BLCF	74B	Boeing 747 LCF Dreamlifter
BN2P	BNI	Pilatus Britten-Norman BN-2A/B Islander
C130	LOH	Lockheed L-182 / 282 / 382 (L-100) Hercules
C152		Cessna 152
C162	CN1	Cessna 162
C172	CN1	Cessna 172
C72R	CN1	Cessna 172 Cutlass RG
C77R	CN1	Cessna 177 Cardinal RG
C182	CN1	Cessna 182 Skylane
C208	CN1	Cessna 208 Caravan
C210	CN1	Cessna 210 Centurion
C212	CS2	CASA / IPTN 212 Aviocar
C25A	CNJ	Cessna Citation CJ2
C25B	CNJ	Cessna Citation CJ3
C25C	CNJ	Cessna Citation CJ4
C46	CWC	Curtiss C-46 Commando
C500	CNJ	Cessna Citation I
C510	CNJ	Cessna Citation Mustang
C525	CNJ	Cessna CitationJet
C550	CNJ	Cessna Citation II
C560	CNJ	Cessna Citation V
C56X	CNJ	Cessna Citation Excel
C650	CNJ	Cessna Citation III, VI, VII
C680	CNJ	Cessna Citation Sovereign
C750	CNJ	Cessna Citation X
CL2T		Bombardier 415
CL30		Bombardier BD-100 Challenger 300
CL44	CL4	Canadair CL-44
CL60	CCJ	Canadair Challenger
CN35	CS5	CASA/IPTN CN-235
CONC	SSC	Concorde
CONI	L49	Lockheed L-1049 Super Constellation
CRJ1	CR1	Canadair Regional Jet 100
CRJ2	CR2	Canadair Regional Jet 200
CRJ7	CR7	Canadair Regional Jet 700
CRJ9	CR9	Canadair Regional Jet 900
CRJX	CRK	Canadair Regional Jet 1000
CVLP	CV4	Convair CV-240 & -440
CVLT	CV5	Convair CV-580, Convair CV-600, Convair CV-640
D228	D28	Fairchild Dornier Do.228
D328	D38	Fairchild Dornier Do.328
DC10	D10	Douglas DC-10
DC3	D3F	Douglas DC-3
DC6	D6F	Douglas DC-6
DC85	D8T	Douglas DC-8-50
DC86	D8L	Douglas DC-8-62
DC87	D8Q	Douglas DC-8-72
DC91	D91	Douglas DC-9-10
DC92	D92	Douglas DC-9-20
DC93	D93	Douglas DC-9-30
DC94	D94	Douglas DC-9-40
DC95	D95	Douglas DC-9-50
DH2T	DHR	De Havilland Canada DHC-2 Turbo-Beaver
DH8A	DH1	De Havilland Canada DHC-8-100 Dash 8 / 8Q
DH8B	DH2	De Havilland Canada DHC-8-200 Dash 8 / 8Q
DH8C	DH3	De Havilland Canada DHC-8-300 Dash 8 / 8Q
DH8D	DH4	De Havilland Canada DHC-8-400 Dash 8Q
DHC2	DHP	De Havilland Canada DHC-2 Beaver
DHC3	DHL	De Havilland Canada DHC-3 Otter
DHC4	DHC	De Havilland Canada DHC-4 Caribou
DHC5	DHC	De Havilland Canada DHC-5 Buffalo
DHC6	DHT	De Havilland Canada DHC-6 Twin Otter
DHC7	DH7	De Havilland Canada DHC-7 Dash 7
DOVE	DHD	De Havilland DH.104 Dove
E110	EMB	Embraer EMB 110 Bandeirante
E120	EM2	Embraer EMB 120 Brasilia
E135	ER3	Embraer RJ135
E135	ERD	Embraer RJ140
E145	ER4	Embraer RJ145
E170	E70	Embraer 170
E190	E90	Embraer 190
E195	E95	Embraer 195
E35L	ER3	Embraer Legacy 600 / Legacy 650
E545		Embraer Legacy 450
E190	E90	Embraer Lineage 1000
E50P	EP1	Embraer Phenom 100
E55P	EP3	Embraer Phenom 300
E75L	E7W	Embraer 175 (long wing)
E75S	E7W	Embraer 175 (short wing)
F100	100	Fokker 100
F27	F27	Fokker F27 Friendship
F28	F21	Fokker F28 Fellowship
F2TH	D20	Dassault Falcon 2000
F406	CNT	Reims-Cessna F406 Caravan II
F50	F50	Fokker 50
F70	F70	Fokker 70
F900	DF9	Dassault Falcon 900
FA7X	DF7	Dassault Falcon 7X
G159	GRS	Gulfstream Aerospace G-159 Gulfstream I
G21	GRG	Grumman G-21 Goose
G280	GR3	Gulfstream G280
G73T	GRM	Grumman G-73 Turbo Mallard
GL5T	CCX	Bombardier BD-700 Global 5000
GLEX	CCX	Bombardier Global Express / Raytheon Sentinel
GLF4	GJ4	Gulfstream IV
GLF5	GJ5	Gulfstream V
GLF6	GJ6	Gulfstream G650
HERN	DHH	De Havilland DH.114 Heron
H25B	H25	British Aerospace 125 series / Hawker/Raytheon 700/800/800XP/850/900
H25C	H25	British Aerospace 125-1000 series / Hawker/Raytheon 1000
HDJT		Honda HA-420
I114	I14	Ilyushin IL114
IL18	IL8	Ilyushin IL18
IL62	IL6	Ilyushin IL62
IL76	IL7	Ilyushin IL76
IL86	ILW	Ilyushin IL86
IL96	I93	Ilyushin IL96
J328	FRJ	Fairchild Dornier 328JET
JS31	J31	British Aerospace Jetstream 31
JS32	J32	British Aerospace Jetstream 32
JS41	J41	British Aerospace Jetstream 41
JU52	JU5	Junkers Ju52/3M
L101	L10	Lockheed L-1011 Tristar
L188	LOE	Lockheed L-188 Electra
L410	L4T	LET 410
LJ35	LRJ	Learjet 35 / 36 / C-21A
LJ60	LRJ	Learjet 60
MD11	M11	McDonnell Douglas MD-11
MD81	M81	McDonnell Douglas MD-81
MD82	M82	McDonnell Douglas MD-82
MD83	M83	McDonnell Douglas MD-83
MD87	M87	McDonnell Douglas MD-87
MD88	M88	McDonnell Douglas MD-88
MD90	M90	McDonnell Douglas MD-90
MI8	MIH	MIL Mi-8 / Mi-17 / Mi-171 / Mil-172
MI24		Mil Mi-24 / Mi-25 / Mi-35
MU2	MU2	Mitsubishi Mu-2
N262	ND2	Aerospatiale (Nord) 262
NOMA	CD2	Government Aircraft Factories N22B / N24A Nomad
P06T		Tecnam P2006T
P28A		Piper PA-28 (up to 180 hp)
P28B		Piper PA-28 (above 200 hp)
P68	PN6	Partenavia P.68
PA31	PA2	Piper PA-31 Navajo
PA44		Piper PA-44 Seminole
PA46	PAG	Piper PA-46
PC12	PL2	Pilatus PC-12
PC6T	PL6	Pilatus PC-6 Turbo Porter
RJ1H	AR1	Avro RJ100
R200		Robin HR200/R2000 series, Alpha160A
RJ70	AR7	Avro RJ70
RJ85	AR8	Avro RJ85
S210	CRV	Aerospatiale (Sud Aviation) Se.210 Caravelle
S58T	S58	Sikorsky S-58T
S601	NDC	Aerospatiale SN.601 Corvette
S61	S61	Sikorsky S-61
S76	S76	Sikorsky S-76
S92	S92	Sikorsky S-92
SB20	S20	Saab 2000
SC7	SHS	Shorts SC-7 Skyvan
SF34	SF3	Saab SF340A/B
SH33	SH3	Shorts SD.330
SH36	SH6	Shorts SD.360
SU95	SU9	Sukhoi Superjet 100-95
TRF1		Team Rocket F1
T134	TU3	Tupolev Tu-134
T144		Tupolev Tu-144
T154	TU5	Tupolev Tu-154
T204	T20	Tupolev Tu-204 / Tu-214
TB20		Socata TB-20 Trinidad
TL20		TL Ultralight TL-96 Star / TL-2000 Sting
TRIS	BNT	Pilatus Britten-Norman BN-2A Mk III Trislander
WW24	WWP	Israel Aircraft Industries 1124 Westwind
Y12	YN2	Harbin Yunshuji Y12
YK40	YK4	Yakovlev Yak-40
YK42	YK2	Yakovlev Yak-42
YS11	YS1	NAMC YS-11
"""

aircraft_data
|> String.trim()
|> String.split("\n")
|> Enum.map(fn line ->
  [icao, iata, desc] = String.split(line, "\t")
  %AircraftType{iata_code: iata, icao_code: icao, description: desc}
end)
|> Enum.each(fn x ->
  Myflightmap.Repo.insert(x, on_conflict: :replace_all, conflict_target: :iata_code)
end)

for path <- Path.wildcard("priv/data/icao/aircraft_types/*.json") do
  path
  |> File.read!()
  |> Jason.decode!(%{keys: :atoms})
  |> Enum.each(fn data ->
    attrs =
      data
      |> Map.take([:engine_type, :engine_count, :manufacturer_code])
      |> Map.to_list()

    icao_code = data.tdesig

    from(a in AircraftType, where: a.icao_code == ^icao_code)
    |> Repo.update_all(set: attrs)
  end)
end
