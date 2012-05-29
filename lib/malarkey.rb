class Malarkey
  def initialize(*data)
    sow(data)
  end

  def hash(data)
    n = 0xefc8249d
    h = 0
    d = data.to_s

    d.each_codepoint { |cp|
      n += cp
      h = 0.02519603282416938 * n
      n = h.to_i
      h -= n
      h *= n
      n = h.to_i
      h -= n
      n += h * 0x100000000 # 2^32
    }

    n.to_i * 2.3283064365386963e-10 # 2^-32
  end

  def rnd
    t = 2091639 * @s0 + @c * 2.3283064365386963e-10 # 2^-32

    @c = t.to_i
    @s0 = @s1
    @s1 = @s2
    @s2 = t - @c

    @s2
  end

  def sow(*data)
    @s0 = hash(' ')
    @s1 = hash(@s0)
    @s2 = hash(@s1)
    @c = 1

    data.each { |d|
      @s0 -= hash(d)
      @s0 += 1 if @s0 < 0

      @s1 -= hash(d)
      @s1 += 1 if @s1 < 0

      @s2 -= hash(d)
      @s2 += 1 if @s2 < 0
    }
  end

  def uint32
    rnd * 0x100000000
  end

  def fract32
    rnd + (rnd * 0x200000).to_i * 1.1102230246251565e-16 # 2^-53
  end

  def integer
    uint32
  end

  def frac
    fract32
  end

  def real
    uint32 + fract32
  end

  def integer_in_range(min=0, max=0)
    real_in_range(min, max).floor
  end

  def real_in_range(min=0, max=0)
    frac * (max - min) + min
  end

  def normal
    1.0 - 2.0 * frac
  end

  def uuid
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.gsub!(/[xy]/) do |c|
      r = integer_in_range(0, 16)
      if c == 'x'
        v = r
      else
        v = (r&0x3|0x8)
      end
      v.to_s(16)
    end
  end

  def pick(ary)
    ary[integer_in_range(0, ary.length)]
  end

  def weighted_pick(ary)
    ary[(frac**2).to_i * ary.length]
  end

  def word
    pick(DATA[:lipsum])
  end

  def words(num=3)
    ret = []
    (0..num).each do |i|
      ret.push(word)
    end

    ret.join(' ')
  end

  def sentence
    (words(integer_in_range(2, 16)).capitalize) + '.'
  end
  
  def sentences(num=3)
    ret = []

    (0..num).each do |i|
      ret.push(sentence)
    end

    ret.join(' ')
  end

  def timestamp(min=946684800, max=1577862000)
    real_in_range(min, max)
  end

  def first_name
    "#{pick(DATA[:names][:first])}"
  end

  def last_name
    "#{pick(DATA[:names][:last])}"
  end

  def name
    "#{pick(DATA[:names][:first])} #{pick(DATA[:names][:last])}"
  end

  def job_title
    "#{pick(DATA[:departments])} #{pick(DATA[:positions])}"
  end

  def buzz_phrase
    "#{pick(DATA[:buzz][:verbs])} #{pick(DATA[:buzz][:adjectives])} #{pick(DATA[:buzz][:nouns])}"
  end

  DATA = {
    lipsum: [
      "lorem", "ipsum", "dolor", "sit", "amet", "consectetur",
      "adipiscing", "elit", "nunc", "sagittis", "tortor", "ac", "mi",
      "pretium", "sed", "convallis", "massa", "pulvinar", "curabitur",
      "non", "turpis", "velit", "vitae", "rutrum", "odio", "aliquam",
      "sapien", "orci", "tempor", "sed", "elementum", "sit", "amet",
      "tincidunt", "sed", "risus", "etiam", "nec", "lacus", "id", "ante",
      "hendrerit", "malesuada", "donec", "porttitor", "magna", "eget",
      "libero", "pharetra", "sollicitudin", "aliquam", "mattis", "mattis",
      "massa", "et", "porta", "morbi", "vitae", "magna", "augue",
      "vestibulum", "at", "lectus", "sed", "tellus", "facilisis",
      "tincidunt", "suspendisse", "eros", "magna", "consequat", "at",
      "sollicitudin", "ac", "vestibulum", "vel", "dolor", "in", "egestas",
      "lacus", "quis", "lacus", "placerat", "et", "molestie", "ipsum",
      "scelerisque", "nullam", "sit", "amet", "tortor", "dui", "aenean",
      "pulvinar", "odio", "nec", "placerat", "fringilla", "neque", "dolor"
    ],
    names: {
      first: [
        "Jacob", "Isabella", "Ethan", "Emma", "Michael", "Olivia",
        "Alexander", "Sophia", "William", "Ava", "Joshua", "Emily",
        "Daniel", "Madison", "Jayden", "Abigail", "Noah", "Chloe",
        "Anthony", "Mia", "Christopher", "Elizabeth", "Aiden",
        "Addison", "Matthew", "Alexis", "David", "Ella", "Andrew",
        "Samantha", "Joseph", "Natalie", "Logan", "Grace", "James",
        "Lily", "Ryan", "Alyssa", "Benjamin", "Ashley", "Elijah",
        "Sarah", "Gabriel", "Taylor", "Christian", "Hannah", "Nathan",
        "Brianna", "Jackson", "Hailey", "John", "Kaylee", "Samuel",
        "Lillian", "Tyler", "Leah", "Dylan", "Anna", "Jonathan",
        "Allison", "Caleb", "Victoria", "Nicholas", "Avery", "Gavin",
        "Gabriella", "Mason", "Nevaeh", "Evan", "Kayla", "Landon",
        "Sofia", "Angel", "Brooklyn", "Brandon", "Riley", "Lucas",
        "Evelyn", "Isaac", "Savannah", "Isaiah", "Aubrey", "Jack",
        "Alexa", "Jose", "Peyton", "Kevin", "Makayla", "Jordan",
        "Layla", "Justin", "Lauren", "Brayden", "Zoe", "Luke", "Sydney",
        "Liam", "Audrey", "Carter", "Julia"
      ],
      last: [
        "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis",
        "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas",
        "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia",
        "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee",
        "Walker", "Hall", "Allen", "Young", "Hernandez", "King",
        "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker",
        "Gonzalez", "Nelson", "Carter", "Mitchell", "Perez", "Roberts",
        "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards",
        "Collins", "Stewart", "Sanchez", "Morris", "Rogers", "Reed",
        "Cook", "Morgan", "Bell", "Murphy", "Bailey", "Rivera",
        "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres",
        "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks",
        "Kelly", "Sanders", "Price", "Bennett", "Wood", "Barnes",
        "Ross", "Henderson", "Coleman", "Jenkins", "Perry", "Powell",
        "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler",
        "Simmons", "Foster", "Gonzales", "Bryant", "Alexander",
        "Russell", "Griffin", "Diaz", "Hayes"
      ]
    },

    departments: ['HR', 'IT', 'Marketing', 'Engineering', 'Sales'],

    positions: ['Director', 'Manager', 'Team Lead', 'Team Member'],

    internet: {
      tlds: ['.com', '.net', '.org', '.edu', '.co.uk']
    },

    buzz: {
      nouns: [
        "action-items", "applications", "architectures", "bandwidth",
        "channels", "communities", "content", "convergence",
        "deliverables", "e-business", "e-commerce", "e-markets",
        "e-services", "e-tailers", "experiences", "eyeballs",
        "functionalities", "infomediaries", "infrastructures",
        "initiatives", "interfaces", "markets", "methodologies",
        "metrics", "mindshare", "models", "networks", "niches",
        "paradigms", "partnerships", "platforms", "portals",
        "relationships", "ROI", "schemas", "solutions", "supply-chains",
        "synergies", "systems", "technologies", "users", "vortals",
        "web services", "web-readiness"
      ],
      adjectives: [
        "24/365", "24/7", "B2B", "B2C", "back-end", "best-of-breed",
        "bleeding-edge", "bricks-and-clicks", "clicks-and-mortar",
        "collaborative", "compelling", "cross-media", "cross-platform",
        "customized", "cutting-edge", "distributed", "dot-com",
        "dynamic", "e-business", "efficient", "end-to-end",
        "enterprise", "extensible", "frictionless", "front-end",
        "global", "granular", "holistic", "impactful", "innovative",
        "integrated", "interactive", "intuitive", "killer",
        "leading-edge", "magnetic", "mission-critical", "multiplatform",
        "next-generation", "one-to-one", "open-source",
        "out-of-the-box", "plug-and-play", "proactive", "real-time",
        "revolutionary", "rich", "robust", "scalable", "seamless",
        "sexy", "sticky", "strategic", "synergistic", "transparent",
        "turn-key", "ubiquitous", "user-centric", "value-added",
        "vertical", "viral", "virtual", "visionary", "web-enabled",
        "wireless", "world-class"
      ],
      verbs: [
        "aggregate", "architect", "benchmark", "brand", "cultivate",
        "deliver", "deploy", "disintermediate", "drive", "e-enable",
        "embrace", "empower", "enable", "engage", "engineer", "enhance",
        "envisioneer", "evolve", "expedite", "exploit", "extend",
        "facilitate", "generate", "grow", "harness", "implement",
        "incentivize", "incubate", "innovate", "integrate", "iterate",
        "leverage", "matrix", "maximize", "mesh", "monetize", "morph",
        "optimize", "orchestrate", "productize", "recontextualize",
        "redefine", "reintermediate", "reinvent", "repurpose",
        "revolutionize", "scale", "seize", "strategize", "streamline",
        "syndicate", "synergize", "synthesize", "target", "transform",
        "transition", "unleash", "utilize", "visualize", "whiteboard"
      ]
    }
  }
end
