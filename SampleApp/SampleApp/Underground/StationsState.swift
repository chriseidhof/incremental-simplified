import Foundation

public struct StationsState: Equatable {
    var stations: [Station] = []
    var lines: [String: [String]] = [:] // line name -> [Station names]
}


extension StationsState {
    func find(byName name: String) -> Station? {
        return stations.first { $0.name == name }
    }
    
    func find(byLine line: String) -> Station? {
        return stations.first { $0.lines.contains(line) }
    }
    
    func find(inZone zone: Int) -> Station? {
        return stations.first { $0.zones.contains(zone) }
    }
}

extension StationsState {
    static var dummyData: StationsState {
        StationsState(stations: allStations, lines: stationsByLine)
    }
}

private let stationsByLine = [
    "Bakerloo": [
        "Harrow & Wealdstone",
        "Kenton",
        "South Kenton",
        "North Wembley",
        "Wembley Central",
        "Stonebridge Park",
        "Harlesden",
        "Willesden Junction",
        "Kensal Green",
        "Queen's Park",
        "Kilburn Park",
        "Maida Vale",
        "Warwick Avenue",
        "Paddington",
        "Edgware Road",
        "Marylebone",
        "Baker Street",
        "Regent's Park",
        "Oxford Circus",
        "Piccadilly Circus",
        "Charing Cross",
        "Embankment",
        "Waterloo",
        "Lambeth North",
        "Elephant & Castle"
    ],
    "Central": [
        "West Ruislip",
        "Ruislip Gardens",
        "South Ruislip",
        "Northolt",
        "Greenford",
        "Perivale",
        "Hanger Lane",
        "Ealing Broadway",
        "West Acton",
        "North Acton",
        "East Acton",
        "White City",
        "Shepherd's Bush",
        "Holland Park",
        "Notting Hill Gate",
        "Queensway",
        "Lancaster Gate",
        "Marble Arch",
        "Bond Street",
        "Oxford Circus",
        "Tottenham Court Road",
        "Holborn",
        "Chancery Lane",
        "St. Paul's",
        "Bank",
        "Liverpool Street",
        "Bethnal Green",
        "Mile End",
        "Stratford",
        "Leyton",
        "Leytonstone",
        "Wanstead",
        "Redbridge",
        "Gants Hill",
        "Newbury Park",
        "Barkingside",
        "Fairlop",
        "Hainault",
        "Grange Hill",
        "Chigwell",
        "Roding Valley",
        "Snaresbrook",
        "South Woodford",
        "Woodford",
        "Buckhurst Hill",
        "Loughton",
        "Debden",
        "Theydon Bois",
        "Epping"
    ],
    "Hammersmith & City": [
        "Hammersmith",
        "Goldhawk Road",
        "Shepherd's Bush Market",
        "Wood Lane",
        "Latimer Road",
        "Ladbroke Grove",
        "Westbourne Park",
        "Royal Oak",
        "Paddington",
        "Edgware Road",
        "Baker Street",
        "Great Portland Street",
        "Euston Square",
        "King's Cross St Pancras",
        "Farringdon",
        "Barbican",
        "Moorgate",
        "Liverpool Street",
        "Aldgate East",
        "Whitechapel",
        "Stepney Green",
        "Mile End",
        "Bow Road",
        "Bromley-by-Bow",
        "West Ham",
        "Plaistow",
        "Upton Park",
        "East Ham",
        "Barking"
    ]
]


private let allStations = [
    Station(
        name: "Acton Town",
        lines: ["District", "Piccadilly"],
        zones: [3]
    ),
    Station(
        name: "Aldgate",
        lines: ["Metropolitan", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Aldgate East",
        lines: ["Hammersmith & City", "District"],
        zones: [1]
    ),
    Station(
        name: "Alperton",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Amersham",
        lines: ["Metropolitan"],
        zones: [9]
    ),
    Station(
        name: "Angel",
        lines: ["Northern"],
        zones: [1]
    ),
    Station(
        name: "Archway",
        lines: ["Northern"],
        zones: [2, 3]
    ),
    Station(
        name: "Arnos Grove",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Arsenal",
        lines: ["Piccadilly"],
        zones: [2]
    ),
    Station(
        name: "Baker Street",
        lines: ["Metropolitan", "Bakerloo", "Circle", "Jubilee", "Hammersmith & City"],
        zones: [1]
    ),
    Station(
        name: "Balham",
        lines: ["Northern"],
        zones: [3]
    ),
    Station(
        name: "Bank",
        lines: ["Waterloo & City", "Northern", "Central"],
        zones: [1]
    ),
    Station(
        name: "Barbican",
        lines: ["Metropolitan", "Circle", "Hammersmith & City"],
        zones: [1]
    ),
    Station(
        name: "Barking",
        lines: ["District", "Hammersmith & City"],
        zones: [4]
    ),
    Station(
        name: "Barkingside",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Barons Court",
        lines: ["District", "Piccadilly"],
        zones: [2]
    ),
    Station(
        name: "Bayswater",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Becontree",
        lines: ["District"],
        zones: [5]
    ),
    Station(
        name: "Belsize Park",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Bermondsey",
        lines: ["Jubilee"],
        zones: [2]
    ),
    Station(
        name: "Bethnal Green",
        lines: ["Central"],
        zones: [2]
    ),
    Station(
        name: "Blackfriars",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Blackhorse Road",
        lines: ["Victoria"],
        zones: [3]
    ),
    Station(
        name: "Bond Street",
        lines: ["Central", "Jubilee"],
        zones: [1]
    ),
    Station(
        name: "Borough",
        lines: ["Northern"],
        zones: [1]
    ),
    Station(
        name: "Boston Manor",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Bounds Green",
        lines: ["Piccadilly"],
        zones: [3, 4]
    ),
    Station(
        name: "Bow Road",
        lines: ["District", "Hammersmith & City"],
        zones: [2]
    ),
    Station(
        name: "Brent Cross",
        lines: ["Northern"],
        zones: [3]
    ),
    Station(
        name: "Brixton",
        lines: ["Victoria"],
        zones: [2]
    ),
    Station(
        name: "Bromley-by-Bow",
        lines: ["District", "Hammersmith & City"],
        zones: [2, 3]
    ),
    Station(
        name: "Buckhurst Hill",
        lines: ["Central"],
        zones: [5]
    ),
    Station(
        name: "Burnt Oak",
        lines: ["Northern"],
        zones: [4]
    ),
    Station(
        name: "Caledonian Road",
        lines: ["Piccadilly"],
        zones: [2]
    ),
    Station(
        name: "Camden Town",
        lines: ["Northern"],
        zones: [2]
    ),

    Station(
        name: "Canada Water",
        lines: ["Jubilee"],
        zones: [2]
    ),
    Station(
        name: "Canary Wharf",
        lines: ["Jubilee"],
        zones: [2]
    ),
    Station(
        name: "Canning Town",
        lines: ["Jubilee"],
        zones: [3]
    ),
    Station(
        name: "Cannon Street",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Canons Park",
        lines: ["Jubilee"],
        zones: [5]
    ),
    Station(
        name: "Chalfont & Latimer",
        lines: ["Metropolitan"],
        zones: [8]
    ),
    Station(
        name: "Chalk Farm",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Chancery Lane",
        lines: ["Central"],
        zones: [1]
    ),
    Station(
        name: "Charing Cross",
        lines: ["Bakerloo", "Northern"],
        zones: [1]
    ),
    Station(
        name: "Chesham",
        lines: ["Metropolitan"],
        zones: [9]
    ),
    Station(
        name: "Chigwell",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Chiswick Park",
        lines: ["District"],
        zones: [3]
    ),
    Station(
        name: "Chorleywood",
        lines: ["Metropolitan"],
        zones: [7]
    ),
    Station(
        name: "Clapham Common",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Clapham North",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Clapham South",
        lines: ["Northern"],
        zones: [2, 3]
    ),
    Station(
        name: "Cockfosters",
        lines: ["Piccadilly"],
        zones: [5]
    ),
    Station(
        name: "Colindale",
        lines: ["Northern"],
        zones: [4]
    ),
    Station(
        name: "Colliers Wood",
        lines: ["Northern"],
        zones: [3]
    ),
    Station(
        name: "Covent Garden",
        lines: ["Piccadilly"],
        zones: [1]
    ),
    Station(
        name: "Croxley",
        lines: ["Metropolitan"],
        zones: [7]
    ),
    Station(
        name: "Dagenham East",
        lines: ["District"],
        zones: [5]
    ),
    Station(
        name: "Dagenham Heathway",
        lines: ["District"],
        zones: [5]
    ),
    Station(
        name: "Debden",
        lines: ["Central"],
        zones: [6]
    ),
    Station(
        name: "Dollis Hill",
        lines: ["Jubilee"],
        zones: [3]
    ),
    Station(
        name: "Ealing Broadway",
        lines: ["District", "Central"],
        zones: [3]
    ),
    Station(
        name: "Ealing Common",
        lines: ["District", "Piccadilly"],
        zones: [3]
    ),
    Station(
        name: "Earl's Court",
        lines: ["District", "Piccadilly"],
        zones: [1, 2]
    ),
    Station(
        name: "East Acton",
        lines: ["Central"],
        zones: [2]
    ),
    Station(
        name: "East Finchley",
        lines: ["Northern"],
        zones: [3]
    ),
    Station(
        name: "East Ham",
        lines: ["District", "Hammersmith & City"],
        zones: [3, 4]
    ),
    Station(
        name: "East Putney",
        lines: ["District"],
        zones: [2, 3]
    ),
    Station(
        name: "Eastcote",
        lines: ["Metropolitan", "Piccadilly"],
        zones: [5]
    ),
    Station(
        name: "Edgware",
        lines: ["Northern"],
        zones: [5]
    ),
    Station(
        name: "Edgware Road",
        lines: ["Bakerloo"],
        zones: [1]
    ),
    Station(
        name: "Edgware Road",
        lines: ["Hammersmith & City", "District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Elephant & Castle",
        lines: ["Northern", "Bakerloo"],
        zones: [1, 2]
    ),
    Station(
        name: "Elm Park",
        lines: ["District"],
        zones: [6]
    ),
    Station(
        name: "Embankment",
        lines: ["District", "Bakerloo", "Northern", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Epping",
        lines: ["Central"],
        zones: [6]
    ),
    Station(
        name: "Euston",
        lines: ["Northern", "Victoria"],
        zones: [1]
    ),
    Station(
        name: "Euston Square",
        lines: ["Metropolitan", "Circle", "Hammersmith & City"],
        zones: [1]
    ),
    Station(
        name: "Fairlop",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Farringdon",
        lines: ["Metropolitan", "Circle", "Hammersmith & City"],
        zones: [1]
    ),
    Station(
        name: "Finchley Central",
        lines: ["Northern"],
        zones: [4]
    ),
    Station(
        name: "Finchley Road",
        lines: ["Metropolitan", "Jubilee"],
        zones: [2]
    ),
    Station(
        name: "Finsbury Park",
        lines: ["Piccadilly", "Victoria"],
        zones: [2]
    ),
    Station(
        name: "Fulham Broadway",
        lines: ["District"],
        zones: [2]
    ),
    Station(
        name: "Gants Hill",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Gloucester Road",
        lines: ["District", "Piccadilly", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Golders Green",
        lines: ["Northern"],
        zones: [3]
    ),
    Station(
        name: "Goldhawk Road",
        lines: ["Hammersmith & City", "Circle"],
        zones: [2]
    ),
    Station(
        name: "Goodge Street",
        lines: ["Northern"],
        zones: [1]
    ),
    Station(
        name: "Grange Hill",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Great Portland Street",
        lines: ["Metropolitan", "Circle", "Hammersmith & City"],
        zones: [1]
    ),
    Station(
        name: "Greenford",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Green Park",
        lines: ["Piccadilly", "Victoria", "Jubilee"],
        zones: [1]
    ),
    Station(
        name: "Gunnersbury",
        lines: ["District"],
        zones: [3]
    ),
    Station(
        name: "Hainault",
        lines: ["Central"],
        zones: [4]
    ),
    /// These are technically two separate stations of the same name.
    ///
    /// - SeeAlso: https://en.wikipedia.org/wiki/Hammersmith_tube_station_(Hammersmith_%26_City_and_Circle_lines)
    /// - SeeAlso: https://en.wikipedia.org/wiki/Hammersmith_tube_station_(Piccadilly_and_District_lines)
    Station(
        name: "Hammersmith",
        lines: ["Hammersmith & City", "Circle"] + ["District", "Piccadilly"],
        zones: [2]
    ),
    Station(
        name: "Hampstead",
        lines: ["Northern"],
        zones: [2, 3]
    ),
    Station(
        name: "Hanger Lane",
        lines: ["Central"],
        zones: [3]
    ),
    Station(
        name: "Harlesden",
        lines: ["Bakerloo"],
        zones: [3]
    ),
    Station(
        name: "Harrow & Wealdstone",
        lines: ["Bakerloo"],
        zones: [5]
    ),
    Station(
        name: "Harrow-on-the-Hill",
        lines: ["Metropolitan"],
        zones: [5]
    ),
    Station(
        name: "Hatton Cross",
        lines: ["Piccadilly"],
        zones: [5, 6]
    ),
    Station(
        name: "Heathrow Terminals 1, 2, 3",
        lines: ["Piccadilly"],
        zones: [6]
    ),
    Station(
        name: "Heathrow Terminal 4",
        lines: ["Piccadilly"],
        zones: [6]
    ),
    Station(
        name: "Heathrow Terminal 5",
        lines: ["Piccadilly"],
        zones: [6]
    ),
    Station(
        name: "Hendon Central",
        lines: ["Northern"],
        zones: [3, 4]
    ),
    Station(
        name: "High Barnet",
        lines: ["Northern"],
        zones: [5]
    ),
    Station(
        name: "Highbury & Islington",
        lines: ["Victoria"],
        zones: [2]
    ),
    Station(
        name: "Highgate",
        lines: ["Northern"],
        zones: [3]
    ),
    Station(
        name: "High Street Kensington",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Hillingdon",
        lines: ["Metropolitan", "Piccadilly"],
        zones: [6]
    ),
    Station(
        name: "Holborn",
        lines: ["Central", "Piccadilly"],
        zones: [1]
    ),
    Station(
        name: "Holland Park",
        lines: ["Central"],
        zones: [2]
    ),
    Station(
        name: "Holloway Road",
        lines: ["Piccadilly"],
        zones: [2]
    ),
    Station(
        name: "Hornchurch",
        lines: ["District"],
        zones: [6]
    ),
    Station(
        name: "Hounslow Central",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Hounslow East",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Hounslow West",
        lines: ["Piccadilly"],
        zones: [5]
    ),
    Station(
        name: "Hyde Park Corner",
        lines: ["Piccadilly"],
        zones: [1]
    ),
    Station(
        name: "Ickenham",
        lines: ["Metropolitan", "Piccadilly"],
        zones: [6]
    ),
    Station(
        name: "Kennington",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Kensal Green",
        lines: ["Bakerloo"],
        zones: [2]
    ),
    Station(
        name: "Kensington (Olympia)",
        lines: ["District"],
        zones: [2]
    ),
    Station(
        name: "Kentish Town",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Kenton",
        lines: ["Bakerloo"],
        zones: [4]
    ),
    Station(
        name: "Kew Gardens",
        lines: ["District"],
        zones: [3, 4]
    ),
    Station(
        name: "Kilburn",
        lines: ["Jubilee"],
        zones: [2]
    ),
    Station(
        name: "Kilburn Park",
        lines: ["Bakerloo"],
        zones: [2]
    ),
    Station(
        name: "Kingsbury",
        lines: ["Jubilee"],
        zones: [4]
    ),
    Station(
        name: "King's Cross St. Pancras",
        lines: ["Metropolitan", "Northern", "Piccadilly", "Circle", "Victoria", "Hammersmith & City"],
        zones: [1]
    ),
    Station(
        name: "Knightsbridge",
        lines: ["Piccadilly"],
        zones: [1]
    ),
    Station(
        name: "Ladbroke Grove",
        lines: ["Hammersmith & City", "Circle"],
        zones: [2]
    ),
    Station(
        name: "Lambeth North",
        lines: ["Bakerloo"],
        zones: [1]
    ),
    Station(
        name: "Lancaster Gate",
        lines: ["Central"],
        zones: [1]
    ),
    Station(
        name: "Latimer Road",
        lines: ["Hammersmith & City", "Circle"],
        zones: [2]
    ),
    Station(
        name: "Leicester Square",
        lines: ["Piccadilly", "Northern"],
        zones: [1]
    ),
    Station(
        name: "Leyton",
        lines: ["Central"],
        zones: [3]
    ),
    Station(
        name: "Leytonstone",
        lines: ["Central"],
        zones: [3, 4]
    ),
    Station(
        name: "Liverpool Street",
        lines: ["Metropolitan", "Central", "Circle", "Hammersmith & City"],
        zones: [1]
    ),
    Station(
        name: "London Bridge",
        lines: ["Northern", "Jubilee"],
        zones: [1]
    ),
    Station(
        name: "Loughton",
        lines: ["Central"],
        zones: [6]
    ),
    Station(
        name: "Maida Vale",
        lines: ["Bakerloo"],
        zones: [2]
    ),
    Station(
        name: "Manor House",
        lines: ["Piccadilly"],
        zones: [2, 3]
    ),
    Station(
        name: "Mansion House",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Marble Arch",
        lines: ["Central"],
        zones: [1]
    ),
    Station(
        name: "Marylebone",
        lines: ["Bakerloo"],
        zones: [1]
    ),
    Station(
        name: "Mile End",
        lines: ["District", "Hammersmith & City", "Central"],
        zones: [2]
    ),
    Station(
        name: "Mill Hill East",
        lines: ["Northern"],
        zones: [4]
    ),
    Station(
        name: "Monument",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Moorgate",
        lines: ["Metropolitan", "Northern", "Circle", "Hammersmith & City"],
        zones: [1]
    ),
    Station(
        name: "Moor Park",
        lines: ["Metropolitan"],
        zones: [6, 7]
    ),
    Station(
        name: "Morden",
        lines: ["Northern"],
        zones: [4]
    ),
    Station(
        name: "Mornington Crescent",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Neasden",
        lines: ["Jubilee"],
        zones: [3]
    ),
    Station(
        name: "Newbury Park",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "North Acton",
        lines: ["Central"],
        zones: [2, 3]
    ),
    Station(
        name: "North Ealing",
        lines: ["Piccadilly"],
        zones: [3]
    ),
    Station(
        name: "North Greenwich",
        lines: ["Jubilee"],
        zones: [2, 3]
    ),
    Station(
        name: "North Harrow",
        lines: ["Metropolitan"],
        zones: [5]
    ),
    Station(
        name: "North Wembley",
        lines: ["Bakerloo"],
        zones: [4]
    ),
    Station(
        name: "Northfields",
        lines: ["Piccadilly"],
        zones: [3]
    ),
    Station(
        name: "Northolt",
        lines: ["Central"],
        zones: [5]
    ),
    Station(
        name: "Northwick Park",
        lines: ["Metropolitan"],
        zones: [4]
    ),
    Station(
        name: "Northwood",
        lines: ["Metropolitan"],
        zones: [6]
    ),
    Station(
        name: "Northwood Hills",
        lines: ["Metropolitan"],
        zones: [6]
    ),
    Station(
        name: "Notting Hill Gate",
        lines: ["District", "Central", "Circle"],
        zones: [1, 2]
    ),
    Station(
        name: "Oakwood",
        lines: ["Piccadilly"],
        zones: [5]
    ),
    Station(
        name: "Old Street",
        lines: ["Northern"],
        zones: [1]
    ),
    Station(
        name: "Osterley",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Oval",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Oxford Circus",
        lines: ["Central", "Bakerloo", "Victoria"],
        zones: [1]
    ),
    Station(
        name: "Paddington",
        lines: ["Hammersmith & City", "District", "Circle", "Bakerloo"],
        zones: [1]
    ),
    Station(
        name: "Park Royal",
        lines: ["Piccadilly"],
        zones: [3]
    ),
    Station(
        name: "Parsons Green",
        lines: ["District"],
        zones: [2]
    ),
    Station(
        name: "Perivale",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Piccadilly Circus",
        lines: ["Bakerloo", "Piccadilly"],
        zones: [1]
    ),
    Station(
        name: "Pimlico",
        lines: ["Victoria"],
        zones: [1]
    ),
    Station(
        name: "Pinner",
        lines: ["Metropolitan"],
        zones: [5]
    ),
    Station(
        name: "Plaistow",
        lines: ["District", "Hammersmith & City"],
        zones: [3]
    ),
    Station(
        name: "Preston Road",
        lines: ["Metropolitan"],
        zones: [4]
    ),
    Station(
        name: "Putney Bridge",
        lines: ["District"],
        zones: [2]
    ),
    Station(
        name: "Queen's Park",
        lines: ["Bakerloo"],
        zones: [2]
    ),
    Station(
        name: "Queensbury",
        lines: ["Jubilee"],
        zones: [4]
    ),
    Station(
        name: "Queensway",
        lines: ["Central"],
        zones: [1]
    ),
    Station(
        name: "Ravenscourt Park",
        lines: ["District"],
        zones: [2]
    ),
    Station(
        name: "Rayners Lane",
        lines: ["Metropolitan", "Piccadilly"],
        zones: [5]
    ),
    Station(
        name: "Redbridge",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Regent's Park",
        lines: ["Bakerloo"],
        zones: [1]
    ),
    Station(
        name: "Richmond",
        lines: ["District"],
        zones: [4]
    ),
    Station(
        name: "Rickmansworth",
        lines: ["Metropolitan"],
        zones: [7]
    ),
    Station(
        name: "Roding Valley",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Royal Oak",
        lines: ["Hammersmith & City", "Circle"],
        zones: [2]
    ),
    Station(
        name: "Ruislip",
        lines: ["Metropolitan", "Piccadilly"],
        zones: [6]
    ),
    Station(
        name: "Ruislip Gardens",
        lines: ["Central"],
        zones: [5]
    ),
    Station(
        name: "Ruislip Manor",
        lines: ["Metropolitan", "Piccadilly"],
        zones: [6]
    ),
    Station(
        name: "Russell Square",
        lines: ["Piccadilly"],
        zones: [1]
    ),
    Station(
        name: "St. James's Park",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "St. John's Wood",
        lines: ["Jubilee"],
        zones: [2]
    ),
    Station(
        name: "St. Paul's",
        lines: ["Central"],
        zones: [1]
    ),
    Station(
        name: "Seven Sisters",
        lines: ["Victoria"],
        zones: [3]
    ),
    Station(
        name: "Shepherd's Bush",
        lines: ["Central"],
        zones: [2]
    ),
    Station(
        name: "Shepherd's Bush Market",
        lines: ["Hammersmith & City", "Circle"],
        zones: [2]
    ),
    Station(
        name: "Sloane Square",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Snaresbrook",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "South Ealing",
        lines: ["Piccadilly"],
        zones: [3]
    ),
    Station(
        name: "South Harrow",
        lines: ["Piccadilly"],
        zones: [5]
    ),
    Station(
        name: "South Kensington",
        lines: ["District", "Piccadilly", "Circle"],
        zones: [1]
    ),
    Station(
        name: "South Kenton",
        lines: ["Bakerloo"],
        zones: [4]
    ),
    Station(
        name: "South Ruislip",
        lines: ["Central"],
        zones: [5]
    ),
    Station(
        name: "South Wimbledon",
        lines: ["Northern"],
        zones: [3, 4]
    ),
    Station(
        name: "South Woodford",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Southfields",
        lines: ["District"],
        zones: [3]
    ),
    Station(
        name: "Southgate",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Southwark",
        lines: ["Jubilee"],
        zones: [1]
    ),
    Station(
        name: "Stamford Brook",
        lines: ["District"],
        zones: [2]
    ),
    Station(
        name: "Stanmore",
        lines: ["Jubilee"],
        zones: [5]
    ),
    Station(
        name: "Stepney Green",
        lines: ["District", "Hammersmith & City"],
        zones: [2]
    ),
    Station(
        name: "Stockwell",
        lines: ["Northern", "Victoria"],
        zones: [2]
    ),
    Station(
        name: "Stonebridge Park",
        lines: ["Bakerloo"],
        zones: [3]
    ),
    Station(
        name: "Stratford",
        lines: ["Central", "Jubilee"],
        zones: [3]
    ),
    Station(
        name: "Sudbury Hill",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Sudbury Town",
        lines: ["Piccadilly"],
        zones: [4]
    ),
    Station(
        name: "Swiss Cottage",
        lines: ["Jubilee"],
        zones: [2]
    ),
    Station(
        name: "Temple",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Theydon Bois",
        lines: ["Central"],
        zones: [6]
    ),
    Station(
        name: "Tooting Bec",
        lines: ["Northern"],
        zones: [3]
    ),
    Station(
        name: "Tooting Broadway",
        lines: ["Northern"],
        zones: [3]
    ),
    Station(
        name: "Tottenham Court Road",
        lines: ["Central", "Northern"],
        zones: [1]
    ),
    Station(
        name: "Tottenham Hale",
        lines: ["Victoria"],
        zones: [3]
    ),
    Station(
        name: "Totteridge & Whetstone",
        lines: ["Northern"],
        zones: [4]
    ),
    Station(
        name: "Tower Hill",
        lines: ["District", "Circle"],
        zones: [1]
    ),
    Station(
        name: "Tufnell Park",
        lines: ["Northern"],
        zones: [2]
    ),
    Station(
        name: "Turnham Green",
        lines: ["District", "Piccadilly"],
        zones: [2, 3]
    ),
    Station(
        name: "Turnpike Lane",
        lines: ["Piccadilly"],
        zones: [3]
    ),
    Station(
        name: "Upminster",
        lines: ["District"],
        zones: [6]
    ),
    Station(
        name: "Upminster Bridge",
        lines: ["District"],
        zones: [6]
    ),
    Station(
        name: "Upney",
        lines: ["District"],
        zones: [4]
    ),
    Station(
        name: "Upton Park",
        lines: ["District", "Hammersmith & City"],
        zones: [3]
    ),
    Station(
        name: "Uxbridge",
        lines: ["Metropolitan", "Piccadilly"],
        zones: [6]
    ),
    Station(
        name: "Vauxhall",
        lines: ["Victoria"],
        zones: [1, 2]
    ),
    Station(
        name: "Victoria",
        lines: ["District", "Circle", "Victoria"],
        zones: [1]
    ),
    Station(
        name: "Walthamstow Central",
        lines: ["Victoria"],
        zones: [3]
    ),
    Station(
        name: "Wanstead",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Warren Street",
        lines: ["Northern", "Victoria"],
        zones: [1]
    ),
    Station(
        name: "Warwick Avenue",
        lines: ["Bakerloo"],
        zones: [2]
    ),
    Station(
        name: "Waterloo",
        lines: ["Waterloo & City", "Bakerloo", "Northern", "Jubilee"],
        zones: [1]
    ),
    Station(
        name: "Watford",
        lines: ["Metropolitan"],
        zones: [7]
    ),
    Station(
        name: "Wembley Central",
        lines: ["Bakerloo"],
        zones: [4]
    ),
    Station(
        name: "Wembley Park",
        lines: ["Metropolitan", "Jubilee"],
        zones: [4]
    ),
    Station(
        name: "West Acton",
        lines: ["Central"],
        zones: [3]
    ),
    Station(
        name: "West Brompton",
        lines: ["District"],
        zones: [2]
    ),
    Station(
        name: "West Finchley",
        lines: ["Northern"],
        zones: [4]
    ),
    Station(
        name: "West Ham",
        lines: ["District", "Hammersmith & City", "Jubilee"],
        zones: [3]
    ),
    Station(
        name: "West Hampstead",
        lines: ["Jubilee"],
        zones: [2]
    ),
    Station(
        name: "West Harrow",
        lines: ["Metropolitan"],
        zones: [5]
    ),
    Station(
        name: "West Kensington",
        lines: ["District"],
        zones: [2]
    ),
    Station(
        name: "West Ruislip",
        lines: ["Central"],
        zones: [6]
    ),
    Station(
        name: "Westbourne Park",
        lines: ["Hammersmith & City", "Circle"],
        zones: [2]
    ),
    Station(
        name: "Westminster",
        lines: ["District", "Circle", "Jubilee"],
        zones: [1]
    ),
    Station(
        name: "White City",
        lines: ["Central"],
        zones: [2]
    ),
    Station(
        name: "Whitechapel",
        lines: ["District", "Hammersmith & City"],
        zones: [2]
    ),
    Station(
        name: "Willesden Green",
        lines: ["Jubilee"],
        zones: [2, 3]
    ),
    Station(
        name: "Willesden Junction",
        lines: ["Bakerloo"],
        zones: [2, 3]
    ),
    Station(
        name: "Wimbledon",
        lines: ["District"],
        zones: [3]
    ),
    Station(
        name: "Wimbledon Park",
        lines: ["District"],
        zones: [3]
    ),
    Station(
        name: "Wood Green",
        lines: ["Piccadilly"],
        zones: [3]
    ),
    Station(
        name: "Wood Lane",
        lines: ["Hammersmith & City", "Circle"],
        zones: [2]
    ),
    Station(
        name: "Woodford",
        lines: ["Central"],
        zones: [4]
    ),
    Station(
        name: "Woodside Park",
        lines: ["Northern"],
        zones: [4]
    )
]
